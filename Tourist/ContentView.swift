//
//  ContentView.swift
//  Tourist
//
//  Created by Parth Vats on 11/04/25.
//

import SwiftUI
import CoreLocation
import MapKit


// MARK: - Content View with Tab Navigation

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlanView()
                .tabItem {
                    Label("Plan", systemImage: "map")
                }
                .tag(0)
            
            MapView()
                .tabItem {
                    Label("Map", systemImage: "globe")
                }
                .tag(1)
            
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "binoculars")
                }
                .tag(2)
            
            PassportView()
                .tabItem {
                    Label("Passport", systemImage: "person.fill")
                }
                .tag(3)
        }
    }
}

// MARK: - Plan Tab Views

struct PlanView: View {
    @EnvironmentObject private var tripPlanner: TripPlannerViewModel
    @State private var startDestination = ""
    @State private var endDestination = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 3) // 3 days from now
    @State private var selectedInterests: Set<TravelInterest> = []
    @State private var showItinerary = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    // Background Image with proper scaling constraints
                    Image("himachal_hero")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            // Title with better typography
                            Text("Plan Your Himachal Journey")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.indigo)
                                .padding(.top, 20)
                                .padding(.bottom, 5)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            // Subtitle
                            Text("Customize your perfect adventure")
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .foregroundColor(.secondary)
                                .padding(.bottom, 10)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            // Main form
                            VStack(alignment: .leading, spacing: 15) {
                                formField(title: "Starting Point", placeholder: "e.g., Shimla, Delhi", binding: $startDestination)
                                
                                formField(title: "Final Destination", placeholder: "e.g., Manali, Spiti Valley", binding: $endDestination)
                                
                                // Date selection with improved layout
                                HStack(spacing: 15) {
                                    dateField(title: "Start Date", date: $startDate)
                                    dateField(title: "End Date", date: $endDate, minDate: startDate)
                                }
                                
                                Text("Your Interests")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.top, 5)
                                
                                InterestSelector(selectedInterests: $selectedInterests)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(UIColor.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
                            )
                            .padding(.horizontal, 16)
                            
                            // Generate Button with improved design
                            Button(action: {
                                hideKeyboard()
                                tripPlanner.generateItinerary(
                                    startDestination: startDestination,
                                    endDestination: endDestination,
                                    startDate: startDate,
                                    endDate: endDate,
                                    interests: Array(selectedInterests)
                                )
                                showItinerary = true
                            }) {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("Generate My Yatra")
                                        .font(.system(size: 17, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(height: 54)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)), Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: Color.purple.opacity(0.3), radius: 5, x: 0, y: 2)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                            .disabled(startDestination.isEmpty || endDestination.isEmpty || selectedInterests.isEmpty)
                            .opacity((startDestination.isEmpty || endDestination.isEmpty || selectedInterests.isEmpty) ? 0.6 : 1)
                            
                            // Add bottom padding to ensure visibility on smaller screens
                            Spacer(minLength: max(20, keyboardHeight > 0 ? keyboardHeight : 0))
                        }
                        .padding(.bottom, 20)
                        .frame(minHeight: geometry.size.height - keyboardHeight)
                    }
                    .scrollDismissesKeyboard(.immediately)
                    .scrollIndicators(.hidden)
                }
                .navigationDestination(isPresented: $showItinerary) {
                    ItineraryView()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image(systemName: "mountain.2.fill")
                            .foregroundColor(.indigo)
                    }
                }
                .ignoresSafeArea(.keyboard)
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.keyboardHeight = keyboardFrame.height
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                self.keyboardHeight = 0
            }
        }
    }
    
    // Helper function for form fields
    private func formField(title: String, placeholder: String, binding: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            TextField(placeholder, text: binding)
                .font(.system(size: 15))
                .padding(12)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .submitLabel(.next)
        }
    }
    
    // Helper function for date fields
    private func dateField(title: String, date: Binding<Date>, minDate: Date? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            if let minDate = minDate {
                DatePicker("", selection: date, in: minDate..., displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
            } else {
                DatePicker("", selection: date, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Function to hide the keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// You'll need to add this extension to your project if it doesn't already exist
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct InterestSelector: View {
    @Binding var selectedInterests: Set<TravelInterest>
    
    let allInterests: [TravelInterest] = [
        .adventure, .religious, .nature, .cultural, .hiddenGems, .foodie, .relax
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(allInterests, id: \.self) { interest in
                    InterestChip(
                        interest: interest,
                        isSelected: selectedInterests.contains(interest),
                        action: {
                            if selectedInterests.contains(interest) {
                                selectedInterests.remove(interest)
                            } else {
                                selectedInterests.insert(interest)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct InterestChip: View {
    let interest: TravelInterest
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: interest.icon)
                    .font(.subheadline)
                Text(interest.rawValue.capitalized)
                    .font(.subheadline)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue.opacity(0.8) : Color.gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

struct ItineraryView: View {
    @EnvironmentObject private var tripPlanner: TripPlannerViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your Himachal Journey")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text("\(tripPlanner.startDate?.formatted(date: .long, time: .omitted) ?? "") to \(tripPlanner.endDate?.formatted(date: .long, time: .omitted) ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                if tripPlanner.itineraryDays.isEmpty {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Generating your personalized itinerary...")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 50)
                } else {
                    ForEach(Array(tripPlanner.itineraryDays.enumerated()), id: \.element.id) { index, day in
                        NavigationLink(destination: ItineraryDayDetailView(day: day)) {
                            ItineraryDayCard(day: day, dayNumber: index + 1)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Your Itinerary")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if tripPlanner.itineraryDays.isEmpty {
                // Typically this would be an API call, but for this demo we'll generate mock data
                tripPlanner.generateMockItinerary()
            }
        }
    }
}

struct ItineraryDayCard: View {
    let day: ItineraryDay
    let dayNumber: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Day \(dayNumber)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
                
                Text(day.date.formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Weather alert indicators
                if day.hasWeatherAlert {
                    Image(systemName: day.weatherAlert?.icon ?? "exclamationmark.triangle")
                        .foregroundColor(.orange)
                }
            }
            
            Text(day.mainLocation)
                .font(.title2)
                .fontWeight(.bold)
            
            // Main image
            Image(day.mainImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .cornerRadius(12)
                .clipped()
            
            // Highlights
            VStack(alignment: .leading, spacing: 5) {
                Text("Highlights:")
                    .font(.headline)
                    .padding(.bottom, 2)
                
                ForEach(day.highlights.prefix(3), id: \.self) { highlight in
                    HStack(alignment: .top) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        
                        Text(highlight)
                            .font(.subheadline)
                    }
                }
                
                if day.highlights.count > 3 {
                    Text("+ \(day.highlights.count - 3) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(radius: 3)
        )
        .padding(.horizontal)
    }
}

struct ItineraryDayDetailView: View {
    let day: ItineraryDay
    @State private var selectedSection: String = "Attractions"
    
    let sections = ["Attractions", "Food", "Activities", "Alerts", "Notes"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header image
                Image(day.mainImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                
                VStack(alignment: .leading) {
                    Text(day.mainLocation)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(day.date.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let altitude = day.altitude {
                        HStack {
                            Image(systemName: "mountain.2")
                            Text("Altitude: \(altitude)m")
                                .font(.subheadline)
                        }
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                    }
                }
                .padding(.horizontal)
                
                // Map snippet
                MapSnippet(location: day.locationCoordinate)
                    .frame(height: 150)
                    .cornerRadius(15)
                    .padding(.horizontal)
                
                // Section picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(sections, id: \.self) { section in
                            SectionButton(
                                title: section,
                                isSelected: selectedSection == section,
                                action: { selectedSection = section }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Section content
                VStack(alignment: .leading, spacing: 15) {
                    switch selectedSection {
                    case "Attractions":
                        AttractionsSection(attractions: day.attractions)
                    case "Food":
                        FoodSection(recommendations: day.foodRecommendations)
                    case "Activities":
                        ActivitiesSection(activities: day.activities)
                    case "Alerts":
                        AlertsSection(weatherAlert: day.weatherAlert, roadAlerts: day.roadAlerts)
                    case "Notes":
                        NotesSection(dayId: day.id)
                    default:
                        Text("Section under development")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(radius: 3)
                )
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Day Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Edit/Customize day functionality
                }) {
                    Text("Edit")
                }
            }
        }
    }
}

struct MapSnippet: View {
    let location: CLLocationCoordinate2D
    
    var body: some View {
        // This would be a MapKit implementation
        // For now using a placeholder
        ZStack {
            Color.gray.opacity(0.2)
            VStack {
                Image(systemName: "map")
                    .font(.largeTitle)
                Text("Map of \(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))")
                    .font(.caption)
            }
        }
    }
}

struct SectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

struct AttractionsSection: View {
    let attractions: [Attraction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Places to Visit")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(attractions) { attraction in
                HStack(alignment: .top) {
                    Image(attraction.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(attraction.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Toggle("", isOn: .constant(true))
                                .labelsHidden()
                        }
                        
                        Text(attraction.description)
                            .font(.subheadline)
                            .lineLimit(2)
                        
                        HStack {
                            Label(
                                "Best Time: \(attraction.bestTimeToVisit)",
                                systemImage: "clock"
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            if let difficulty = attraction.difficulty {
                                Label(
                                    difficulty.rawValue,
                                    systemImage: "figure.hiking"
                                )
                                .font(.caption)
                                .foregroundColor(difficulty.color)
                            }
                        }
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }
}

struct FoodSection: View {
    let recommendations: [FoodRecommendation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Local Cuisine")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(recommendations) { food in
                HStack(alignment: .top) {
                    Image(food.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(food.name)
                            .font(.headline)
                        
                        Text(food.description)
                            .font(.subheadline)
                            .lineLimit(2)
                        
                        HStack {
                            ForEach(food.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(Color.green.opacity(0.2))
                                    )
                                    .foregroundColor(.green)
                            }
                        }
                        
                        if let place = food.bestPlace {
                            Label(
                                "Try at: \(place)",
                                systemImage: "fork.knife"
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }
}

struct ActivitiesSection: View {
    let activities: [Activity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Experiences")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(activities) { activity in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: activity.icon)
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        Text(activity.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        if let difficulty = activity.difficulty {
                            DifficultyBadge(difficulty: difficulty)
                        }
                    }
                    
                    Text(activity.description)
                        .font(.subheadline)
                    
                    if let duration = activity.duration {
                        Label(
                            "Duration: \(duration)",
                            systemImage: "clock"
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: Difficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(difficulty.color.opacity(0.2))
            )
            .foregroundColor(difficulty.color)
    }
}

struct AlertsSection: View {
    let weatherAlert: WeatherAlert?
    let roadAlerts: [RoadAlert]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Travel Advisories")
                .font(.title2)
                .fontWeight(.bold)
            
            if let alert = weatherAlert {
                AlertCard(
                    title: "Weather Alert",
                    description: alert.description,
                    icon: alert.icon,
                    color: .orange
                )
            }
            
            ForEach(roadAlerts) { alert in
                AlertCard(
                    title: "Road Condition: \(alert.road)",
                    description: alert.description,
                    icon: alert.status.icon,
                    color: alert.status.color
                )
            }
            
            if weatherAlert == nil && roadAlerts.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("No alerts for this location")
                        .font(.headline)
                    
                    Spacer()
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
}

struct AlertCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                
                Text(description)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct NotesSection: View {
    let dayId: UUID
    @State private var note = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Notes")
                .font(.title2)
                .fontWeight(.bold)
            
            TextEditor(text: $note)
                .frame(minHeight: 150)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Button(action: {
                // Save note functionality
            }) {
                Text("Save Note")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Map Tab

struct MapView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var tripPlanner: TripPlannerViewModel
    @State private var mapType: MapType = .standard
    @State private var showWeatherOverlay = true
    @State private var showRoadConditions = true
    @State private var showEmergencyServices = false
    @State private var showAltitudeInfo = false
    @State private var showingLogSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map placeholder (this would be MapKit in a real app)
                Color.gray.opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        VStack {
                            Image(systemName: "map")
                                .font(.system(size: 50))
                            Text("Interactive Map View")
                                .font(.title)
                                .padding(.top)
                            Text("Current location: \(formatCoordinate(locationManager.currentLocation))")
                                .font(.caption)
                                .padding(.top, 4)
                        }
                    )
                
                // Overlay controls
                VStack {
                    HStack {
                        Spacer()
                        
                        VStack {
                            Button(action: {
                                mapType = mapType == .standard ? .satellite : .standard
                            }) {
                                Image(systemName: mapType == .standard ? "globe" : "map")
                                    .padding()
                                    .background(Circle().fill(Color.white))
                                    .shadow(radius: 3)
                            }
                            
                            MapFilterButton(
                                isActive: $showWeatherOverlay,
                                icon: "cloud.sun.fill",
                                color: .blue
                            )
                            
                            MapFilterButton(
                                isActive: $showRoadConditions,
                                icon: "road.lanes",
                                color: .orange
                            )
                            
                            MapFilterButton(
                                isActive: $showEmergencyServices,
                                icon: "cross.case.fill",
                                color: .red
                            )
                            
                            MapFilterButton(
                                isActive: $showAltitudeInfo,
                                icon: "mountain.2.fill",
                                color: .green
                            )
                        }
                        .padding(.trailing)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingLogSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Log Experience")
                        }
                        .padding()
                        .background(Capsule().fill(Color.blue))
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                    }
                    .padding(.bottom)
                }
                .padding()
            }
            .navigationTitle("Journey Map")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingLogSheet) {
                LogExperienceView()
            }
        }
    }
    
    private func formatCoordinate(_ coordinate: CLLocationCoordinate2D) -> String {
        return "\(String(format: "%.4f", coordinate.latitude)), \(String(format: "%.4f", coordinate.longitude))"
    }
}

struct MapFilterButton: View {
    @Binding var isActive: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            isActive.toggle()
        }) {
            Image(systemName: icon)
                .foregroundColor(isActive ? color : .gray)
                .padding()
                .background(Circle().fill(Color.white))
                .shadow(radius: 3)
        }
    }
}

struct LogExperienceView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var experienceText = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .clipped()
                } else {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        VStack {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                            Text("Add Photo")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                
                TextField("What's special about this place?", text: $experienceText)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Button(action: {
                    // Save experience functionality
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save Experience")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Log Experience")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showImagePicker) {
                // This would be the actual image picker in a real app
                Text("Image Picker Placeholder")
                    .padding()
            }
        }
    }
}

// MARK: - Discover Tab

struct DiscoverView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search attractions, guides, places...", text: $searchText)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .padding(.horizontal)
                    
                    // Categories
                    VStack(alignment: .leading) {
                        Text("Explore Categories")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                CategoryCard(title: "Adventure", image: "adventure", icon: "figure.hiking")
                                CategoryCard(title: "Religious", image: "religious", icon: "building.columns")
                                CategoryCard(title: "Nature", image: "nature", icon: "leaf")
                                CategoryCard(title: "Cultural", image: "cultural", icon: "theatermasks")
                            }
                            .padding(.horizontal)
                        }
                    }
                    // Hidden Gems
                                        VStack(alignment: .leading) {
                                            Text("Hidden Gems")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .padding(.horizontal)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 15) {
                                                    ForEach(mockHiddenGems) { gem in
                                                        HiddenGemCard(gem: gem)
                                                    }
                                                }
                                                .padding(.horizontal)
                                            }
                                        }
                                        
                                        // Local Guides
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text("Local Guides")
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                
                                                Spacer()
                                                
                                                NavigationLink(destination: AllGuidesView()) {
                                                    Text("See All")
                                                        .font(.subheadline)
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                            .padding(.horizontal)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 15) {
                                                    ForEach(mockLocalGuides) { guide in
                                                        LocalGuideCard(guide: guide)
                                                    }
                                                }
                                                .padding(.horizontal)
                                            }
                                        }
                                        
                                        // Upcoming Festivals
                                        VStack(alignment: .leading) {
                                            Text("Festivals Happening Soon")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .padding(.horizontal)
                                            
                                            ForEach(mockFestivals.prefix(3)) { festival in
                                                FestivalCard(festival: festival)
                                                    .padding(.horizontal)
                                            }
                                        }
                                        
                                        // Community Stories
                                        VStack(alignment: .leading) {
                                            Text("Community Stories")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .padding(.horizontal)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 15) {
                                                    ForEach(mockCommunityStories) { story in
                                                        CommunityStoryCard(story: story)
                                                    }
                                                }
                                                .padding(.horizontal)
                                            }
                                        }
                                    }
                                    .padding(.vertical)
                                }
                                .navigationTitle("Discover Himachal")
                                .navigationBarTitleDisplayMode(.large)
                            }
                        }
                    }

                    struct CategoryCard: View {
                        let title: String
                        let image: String
                        let icon: String
                        
                        var body: some View {
                            VStack {
                                Image(image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .shadow(radius: 3)
                                
                                HStack {
                                    Image(systemName: icon)
                                    Text(title)
                                        .font(.headline)
                                }
                                .padding(.vertical, 5)
                            }
                            .frame(width: 120)
                        }
                    }

                    struct HiddenGemCard: View {
                        let gem: HiddenGem
                        
                        var body: some View {
                            VStack(alignment: .leading) {
                                Image(gem.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 150)
                                    .cornerRadius(15)
                                    .overlay(
                                        VStack(alignment: .leading) {
                                            Spacer()
                                            
                                            Text(gem.name)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding(10)
                                                .background(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                                                        startPoint: .bottom,
                                                        endPoint: .top
                                                    )
                                                )
                                        }
                                    )
                                
                                Text(gem.location)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                    
                                    Text("\(gem.visitors) visitors")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    
                                    Text(String(format: "%.1f", gem.rating))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(width: 200)
                        }
                    }

                    struct LocalGuideCard: View {
                        let guide: LocalGuide
                        
                        var body: some View {
                            VStack {
                                Image(guide.profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                    )
                                    .shadow(radius: 3)
                                
                                Text(guide.name)
                                    .font(.headline)
                                
                                Text(guide.specialty.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    ForEach(0..<min(5, Int(guide.rating.rounded())), id: \.self) { _ in
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                    }
                                    
                                    if guide.rating < 5 {
                                        ForEach(0..<min(5, 5 - Int(guide.rating.rounded())), id: \.self) { _ in
                                            Image(systemName: "star")
                                                .foregroundColor(.yellow)
                                                .font(.caption)
                                        }
                                    }
                                }
                                
                                Text("\(guide.languages.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(Color.blue.opacity(0.1))
                                    )
                            }
                            .frame(width: 150)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(radius: 3)
                            )
                        }
                    }

                    struct FestivalCard: View {
                        let festival: Festival
                        
                        var body: some View {
                            HStack(spacing: 15) {
                                Image(festival.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(festival.name)
                                        .font(.headline)
                                    
                                    Text(festival.location)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.red)
                                        
                                        Text(festival.date, style: .date)
                                            .font(.subheadline)
                                            .foregroundColor(.red)
                                    }
                                }
                                
                                Spacer()
                                
                                if festival.isSoon {
                                    Text("Soon")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule()
                                                .fill(Color.orange)
                                        )
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(radius: 1)
                            )
                        }
                    }

                    struct CommunityStoryCard: View {
                        let story: CommunityStory
                        
                        var body: some View {
                            VStack(alignment: .leading) {
                                Image(story.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 250, height: 150)
                                    .cornerRadius(15)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(story.title)
                                        .font(.headline)
                                        .lineLimit(1)
                                    
                                    Text(story.excerpt)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                    
                                    HStack {
                                        Image(story.authorImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 25, height: 25)
                                            .clipShape(Circle())
                                        
                                        Text(story.author)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Text(story.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 5)
                            }
                            .frame(width: 250)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(radius: 3)
                            )
                        }
                    }

                    struct AllGuidesView: View {
                        @State private var searchText = ""
                        @State private var selectedLanguages: Set<String> = []
                        @State private var selectedSpecialties: Set<String> = []
                        
                        let allLanguages = ["English", "Hindi", "French", "German", "Spanish", "Japanese"]
                        let allSpecialties = ["Adventure", "Photography", "Culture", "Wildlife", "Trekking", "Yoga"]
                        
                        var filteredGuides: [LocalGuide] {
                            return mockLocalGuides.filter { guide in
                                (searchText.isEmpty || guide.name.localizedCaseInsensitiveContains(searchText)) &&
                                (selectedLanguages.isEmpty || selectedLanguages.isSubset(of: Set(guide.languages))) &&
                                (selectedSpecialties.isEmpty || guide.specialty.contains(where: { selectedSpecialties.contains($0) }))
                            }
                        }
                        
                        var body: some View {
                            VStack(spacing: 15) {
                                // Search bar
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                    
                                    TextField("Search guides by name", text: $searchText)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.1))
                                )
                                .padding(.horizontal)
                                
                                // Filter options
                                VStack(alignment: .leading) {
                                    Text("Filter by Language")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(allLanguages, id: \.self) { language in
                                                FilterChip(
                                                    title: language,
                                                    isSelected: selectedLanguages.contains(language),
                                                    action: {
                                                        if selectedLanguages.contains(language) {
                                                            selectedLanguages.remove(language)
                                                        } else {
                                                            selectedLanguages.insert(language)
                                                        }
                                                    }
                                                )
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                    Text("Filter by Specialty")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(allSpecialties, id: \.self) { specialty in
                                                FilterChip(
                                                    title: specialty,
                                                    isSelected: selectedSpecialties.contains(specialty),
                                                    action: {
                                                        if selectedSpecialties.contains(specialty) {
                                                            selectedSpecialties.remove(specialty)
                                                        } else {
                                                            selectedSpecialties.insert(specialty)
                                                        }
                                                    }
                                                )
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // Results
                                if filteredGuides.isEmpty {
                                    Spacer()
                                    Text("No guides found matching your criteria")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                } else {
                                    ScrollView {
                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 15) {
                                            ForEach(filteredGuides) { guide in
                                                NavigationLink(destination: GuideDetailView(guide: guide)) {
                                                    LocalGuideCard(guide: guide)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding()
                                    }
                                }
                            }
                            .navigationTitle("Local Guides")
                            .navigationBarTitleDisplayMode(.large)
                        }
                    }

                    struct FilterChip: View {
                        let title: String
                        let isSelected: Bool
                        let action: () -> Void
                        
                        var body: some View {
                            Button(action: action) {
                                Text(title)
                                    .font(.subheadline)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                                    )
                                    .foregroundColor(isSelected ? .white : .primary)
                            }
                        }
                    }

                    struct GuideDetailView: View {
                        let guide: LocalGuide
                        
                        var body: some View {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 20) {
                                    // Header image and profile
                                    ZStack(alignment: .bottom) {
                                        Image("himachal_background")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 200)
                                            .clipped()
                                        
                                        HStack {
                                            Image(guide.profileImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 3)
                                                )
                                                .offset(y: 50)
                                                .padding(.leading)
                                            
                                            Spacer()
                                        }
                                    }
                                    .padding(.bottom, 50)
                                    
                                    // Name and rating
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(guide.name)
                                                .font(.title)
                                                .fontWeight(.bold)
                                            
                                            HStack {
                                                ForEach(0..<5) { index in
                                                    Image(systemName: index < Int(guide.rating) ? "star.fill" : "star")
                                                        .foregroundColor(.yellow)
                                                }
                                                
                                                Text("(\(guide.reviewCount) reviews)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            // Contact action
                                        }) {
                                            Text("Contact")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(Color.blue)
                                                .cornerRadius(10)
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                    // Details
                                    VStack(alignment: .leading, spacing: 15) {
                                        DetailRow(icon: "person.fill.badge.plus", title: "Experience", value: "\(guide.yearsExperience) years")
                                        
                                        DetailRow(icon: "map", title: "Regions", value: guide.regions.joined(separator: ", "))
                                        
                                        DetailRow(icon: "star", title: "Specialty", value: guide.specialty.joined(separator: ", "))
                                        
                                        DetailRow(icon: "globe", title: "Languages", value: guide.languages.joined(separator: ", "))
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white)
                                            .shadow(radius: 3)
                                    )
                                    .padding(.horizontal)
                                    
                                    // About
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("About")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Text(guide.bio)
                                            .font(.body)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white)
                                            .shadow(radius: 3)
                                    )
                                    .padding(.horizontal)
                                    
                                    // Reviews
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Reviews")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        ForEach(guide.reviews) { review in
                                            ReviewCard(review: review)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white)
                                            .shadow(radius: 3)
                                    )
                                    .padding(.horizontal)
                                }
                                .padding(.bottom, 30)
                            }
                            .navigationTitle("Guide Profile")
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }

                    struct DetailRow: View {
                        let icon: String
                        let title: String
                        let value: String
                        
                        var body: some View {
                            HStack {
                                Image(systemName: icon)
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                
                                Text(title)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text(value)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    struct ReviewCard: View {
                        let review: Review
                        
                        var body: some View {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(review.userImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading) {
                                        Text(review.userName)
                                            .font(.headline)
                                        
                                        HStack {
                                            ForEach(0..<5) { index in
                                                Image(systemName: index < review.rating ? "star.fill" : "star")
                                                    .foregroundColor(.yellow)
                                                    .font(.caption)
                                            }
                                            
                                            Text(review.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                
                                Text(review.comment)
                                    .font(.subheadline)
                                    .padding(.top, 5)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }

                    // MARK: - Passport Tab

                    struct PassportView: View {
                        @EnvironmentObject private var userProfile: UserProfileViewModel
                        
                        var body: some View {
                            NavigationView {
                                ScrollView {
                                    VStack(spacing: 25) {
                                        // Profile Header
                                        VStack {
                                            Image(userProfile.profileImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 120, height: 120)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 3)
                                                        .shadow(radius: 5)
                                                )
                                            
                                            Text(userProfile.name)
                                                .font(.title)
                                                .fontWeight(.bold)
                                            
                                            Text("\(userProfile.totalVisits) places visited in Himachal")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        
                                        // Himachal Passport
                                        VStack(alignment: .leading, spacing: 15) {
                                            Text("Himachal Passport")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .padding(.horizontal)
                                            
                                            HimachalPassportView(stamps: userProfile.collectedStamps)
                                                .frame(height: 300)
                                                .padding(.horizontal)
                                        }
                                        
                                        // My Journeys
                                        VStack(alignment: .leading, spacing: 15) {
                                            Text("My Journeys")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .padding(.horizontal)
                                            
                                            ForEach(userProfile.journeys) { journey in
                                                JourneyCard(journey: journey)
                                                    .padding(.horizontal)
                                            }
                                        }
                                        
                                        // My Contributions
                                        VStack(alignment: .leading, spacing: 15) {
                                            Text("My Contributions")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .padding(.horizontal)
                                            
                                            if userProfile.contributions.isEmpty {
                                                Text("You haven't shared any experiences yet.")
                                                    .foregroundColor(.secondary)
                                                    .padding()
                                            } else {
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 15) {
                                                        ForEach(userProfile.contributions) { contribution in
                                                            ContributionCard(contribution: contribution)
                                                        }
                                                    }
                                                    .padding(.horizontal)
                                                }
                                            }
                                        }
                                        
                                        // Settings
                                        VStack {
                                            Button(action: {
                                                // Share journey action
                                            }) {
                                                HStack {
                                                    Image(systemName: "square.and.arrow.up")
                                                    Text("Share Journey")
                                                }
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                            }
                                            .padding(.horizontal)
                                            
                                            Button(action: {
                                                // Settings action
                                            }) {
                                                HStack {
                                                    Image(systemName: "gear")
                                                    Text("Settings")
                                                }
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.gray.opacity(0.2))
                                                .foregroundColor(.primary)
                                                .cornerRadius(10)
                                            }
                                            .padding(.horizontal)
                                        }
                                        .padding(.vertical)
                                    }
                                    .padding(.vertical)
                                }
                                .navigationTitle("My HimYatra")
                                .navigationBarTitleDisplayMode(.large)
                            }
                        }
                    }

                    struct HimachalPassportView: View {
                        let stamps: [PassportStamp]
                        
                        var body: some View {
                            ZStack {
                                // Background passport image
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(red: 0.95, green: 0.95, blue: 0.97))
                                    .overlay(
                                        VStack {
                                            Text("HIMACHAL PASSPORT")
                                                .font(.headline)
                                                .foregroundColor(.blue)
                                                .padding(.top, 20)
                                            
                                            Spacer()
                                        }
                                    )
                                
                                // Stamps layout
                                VStack {
                                    Spacer()
                                        .frame(height: 60)
                                    
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 15) {
                                        ForEach(stamps) { stamp in
                                            PassportStampView(stamp: stamp)
                                        }
                                    }
                                    .padding()
                                    
                                    Spacer()
                                }
                            }
                        }
                    }

                    struct PassportStampView: View {
                        let stamp: PassportStamp
                        
                        var body: some View {
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 70, height: 70)
                                        .shadow(radius: 2)
                                    
                                    Text(stamp.icon)
                                        .font(.system(size: 30))
                                    
                                    Circle()
                                        .stroke(Color.red, lineWidth: 2)
                                        .frame(width: 70, height: 70)
                                        .rotationEffect(Angle(degrees: -30))
                                }
                                
                                Text(stamp.location)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 80)
                            }
                        }
                    }

                    struct JourneyCard: View {
                        let journey: Journey
                        
                        var body: some View {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(journey.title)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Text(journey.status.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule()
                                                .fill(journey.status.color.opacity(0.2))
                                        )
                                        .foregroundColor(journey.status.color)
                                }
                                
                                Text("\(journey.startDate.formatted(date: .abbreviated, time: .omitted)) - \(journey.endDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    ForEach(journey.waypoints.prefix(3), id: \.self) { waypoint in
                                        Text(waypoint)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(5)
                                    }
                                    
                                    if journey.waypoints.count > 3 {
                                        Text("+\(journey.waypoints.count - 3)")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(5)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(radius: 3)
                            )
                        }
                    }

                    struct ContributionCard: View {
                        let contribution: Contribution
                        
                        var body: some View {
                            VStack(alignment: .leading) {
                                Image(contribution.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 150)
                                    .cornerRadius(15)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(contribution.location)
                                        .font(.headline)
                                    
                                    Text(contribution.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                    
                                    Text(contribution.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 5)
                            }
                            .frame(width: 200)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(radius: 3)
                            )
                        }
                    }

                    // MARK: - Models

                    enum MapType {
                        case standard, satellite
                    }

                    enum TravelInterest: String, CaseIterable, Identifiable {
                        case adventure, religious, nature, cultural, hiddenGems = "hidden gems", foodie, relax
                        
                        var id: String { self.rawValue }
                        
                        var icon: String {
                            switch self {
                            case .adventure: return "figure.hiking"
                            case .religious: return "building.columns"
                            case .nature: return "leaf"
                            case .cultural: return "theatermasks"
                            case .hiddenGems: return "sparkles"
                            case .foodie: return "fork.knife"
                            case .relax: return "bed.double"
                            }
                        }
                    }

                    enum Difficulty: String {
                        case easy = "Easy"
                        case moderate = "Moderate"
                        case challenging = "Challenging"
                        case expert = "Expert"
                        
                        var color: Color {
                            switch self {
                            case .easy: return .green
                            case .moderate: return .blue
                            case .challenging: return .orange
                            case .expert: return .red
                            }
                        }
                    }

                    enum RoadStatus {
                        case open, caution, closed
                        
                        var icon: String {
                            switch self {
                            case .open: return "checkmark.circle"
                            case .caution: return "exclamationmark.triangle"
                            case .closed: return "xmark.circle"
                            }
                        }
                        
                        var color: Color {
                            switch self {
                            case .open: return .green
                            case .caution: return .orange
                            case .closed: return .red
                            }
                        }
                    }

                    enum JourneyStatus: String {
                        case upcoming = "Upcoming"
                        case ongoing = "Ongoing"
                        case completed = "Completed"
                        
                        var color: Color {
                            switch self {
                            case .upcoming: return .blue
                            case .ongoing: return .green
                            case .completed: return .purple
                            }
                        }
                    }

                    struct ItineraryDay: Identifiable {
                        let id = UUID()
                        let date: Date
                        let mainLocation: String
                        let mainImage: String
                        let highlights: [String]
                        let altitude: Int?
                        let locationCoordinate: CLLocationCoordinate2D
                        let hasWeatherAlert: Bool
                        let weatherAlert: WeatherAlert?
                        let roadAlerts: [RoadAlert]
                        let attractions: [Attraction]
                        let foodRecommendations: [FoodRecommendation]
                        let activities: [Activity]
                    }

                    struct WeatherAlert: Identifiable {
                        let id = UUID()
                        let type: String
                        let description: String
                        let icon: String
                    }

                    struct RoadAlert: Identifiable {
                        let id = UUID()
                        let road: String
                        let description: String
                        let status: RoadStatus
                    }

                    struct Attraction: Identifiable {
                        let id = UUID()
                        let name: String
                        let description: String
                        let image: String
                        let bestTimeToVisit: String
                        let difficulty: Difficulty?
                    }

                    struct FoodRecommendation: Identifiable {
                        let id = UUID()
                        let name: String
                        let description: String
                        let image: String
                        let tags: [String]
                        let bestPlace: String?
                    }

                    struct Activity: Identifiable {
                        let id = UUID()
                        let name: String
                        let description: String
                        let icon: String
                        let difficulty: Difficulty?
                        let duration: String?
                    }

                    struct HiddenGem: Identifiable {
                        let id = UUID()
                        let name: String
                        let location: String
                        let image: String
                        let visitors: Int
                        let rating: Double
                    }

                    struct LocalGuide: Identifiable {
                        let id = UUID()
                        let name: String
                        let profileImage: String
                        let specialty: [String]
                        let languages: [String]
                        let rating: Double
                        let reviewCount: Int
                        let yearsExperience: Int
                        let regions: [String]
                        let bio: String
                        let reviews: [Review]
                    }

                    struct Review: Identifiable {
                        let id = UUID()
                        let userName: String
                        let userImage: String
                        let rating: Int
                        let date: Date
                        let comment: String
                    }

                    struct Festival: Identifiable {
                        let id = UUID()
                        let name: String
                        let location: String
                        let image: String
                        let date: Date
                        let description: String
                        
                        var isSoon: Bool {
                            let calendar = Calendar.current
                            let now = Date()
                            let dateComponents = calendar.dateComponents([.day], from: now, to: date)
                            return date > now && dateComponents.day ?? 0 < 30
                        }
                    }

                    struct CommunityStory: Identifiable {
                        let id = UUID()
                        let title: String
                        let excerpt: String
                        let image: String
                        let author: String
                        let authorImage: String
                        let date: Date
                    }

                    struct PassportStamp: Identifiable {
                        let id = UUID()
                        let location: String
                        let icon: String
                        let date: Date
                    }

                    struct Journey: Identifiable {
                        let id = UUID()
                        let title: String
                        let startDate: Date
                        let endDate: Date
                        let waypoints: [String]
                        let status: JourneyStatus
                    }

                    struct Contribution: Identifiable {
                        let id = UUID()
                        let location: String
                        let description: String
                        let image: String
                        let date: Date
                    }

                    // MARK: - View Models

                    class TripPlannerViewModel: ObservableObject {
                        @Published var startDestination: String?
                        @Published var endDestination: String?
                        @Published var startDate: Date?
                        @Published var endDate: Date?
                        @Published var selectedInterests: [TravelInterest] = []
                        @Published var itineraryDays: [ItineraryDay] = []
                        
                        func generateItinerary(startDestination: String, endDestination: String, startDate: Date, endDate: Date, interests: [TravelInterest]) {
                            self.startDestination = startDestination
                            self.endDestination = endDestination
                            self.startDate = startDate
                            self.endDate = endDate
                            self.selectedInterests = interests
                            
                            // In a real app, this would make an API call to generate the itinerary
                            // For this demo, we'll populate with mock data in generateMockItinerary()
                            itineraryDays = []
                        }
                        
                        func generateMockItinerary() {
                            let calendar = Calendar.current
                            
                            guard let startDate = startDate, let endDate = endDate else {
                                return
                            }
                            
                            let numberOfDays = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 3
                            
                            var days: [ItineraryDay] = []
                            
                            // Sample locations for Himachal itinerary
                            let locations = [
                                ("Shimla", "shimla_image", 2206),
                                ("Manali", "manali_image", 2050),
                                ("Dharamshala", "dharamshala_image", 1457),
                                ("Dalhousie", "dalhousie_image", 1970),
                                ("Spiti Valley", "spiti_image", 4270)
                            ]
                            
                            for i in 0..<min(numberOfDays, locations.count) {
                                let currentDate = calendar.date(byAdding: .day, value: i, to: startDate) ?? startDate
                                let (location, image, altitude) = locations[i]
                                
                                let hasWeatherAlert = i == 2 // Example: weather alert on day 3
                                
                                let day = ItineraryDay(
                                    date: currentDate,
                                    mainLocation: location,
                                    mainImage: image,
                                    highlights: mockHighlightsFor(location),
                                    altitude: altitude,
                                    locationCoordinate: mockCoordinateFor(location),
                                    hasWeatherAlert: hasWeatherAlert,
                                    weatherAlert: hasWeatherAlert ? WeatherAlert(
                                        type: "Rain",
                                        description: "Moderate to heavy rainfall expected in the afternoon. Plan indoor activities or carry rain gear.",
                                        icon: "cloud.rain"
                                    ) : nil,
                                    roadAlerts: mockRoadAlertsFor(location),
                                    attractions: mockAttractionsFor(location),
                                    foodRecommendations: mockFoodRecommendationsFor(location),
                                    activities: mockActivitiesFor(location)
                                )
                                
                                days.append(day)
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                                self?.itineraryDays = days
                            }
                        }
                        
                        // Helper functions to generate mock data
                        private func mockHighlightsFor(_ location: String) -> [String] {
                            switch location {
                            case "Shimla":
                                return ["The Ridge", "Mall Road", "Jakhu Temple", "Christ Church", "Kufri Adventure Park"]
                            case "Manali":
                                return ["Rohtang Pass", "Solang Valley", "Hidimba Devi Temple", "Old Manali", "Vashisht Hot Springs"]
                            case "Dharamshala":
                                return ["Mcleodganj", "Dharamkot", "Bhagsu Waterfall", "Namgyal Monastery", "Tibet Museum"]
                            case "Dalhousie":
                                return ["Khajjiar", "Dainkund Peak", "Kalatop Wildlife Sanctuary", "St. John's Church", "Panchpula"]
                            case "Spiti Valley":
                                return ["Key Monastery", "Chandratal Lake", "Kunzum Pass", "Dhankar Monastery", "Pin Valley National Park"]
                            default:
                                return ["Local sightseeing", "Nature walks", "Cultural experiences"]
                            }
                        }
                        
                        private func mockCoordinateFor(_ location: String) -> CLLocationCoordinate2D {
                            switch location {
                            case "Shimla":
                                return CLLocationCoordinate2D(latitude: 31.1048, longitude: 77.1734)
                            case "Manali":
                                return CLLocationCoordinate2D(latitude: 32.2396, longitude: 77.1887)
                            case "Dharamshala":
                                return CLLocationCoordinate2D(latitude: 32.2190, longitude: 76.3234)
                            case "Dalhousie":
                                return CLLocationCoordinate2D(latitude: 32.5387, longitude: 75.9701)
                            case "Spiti Valley":
                                return CLLocationCoordinate2D(latitude: 32.2461, longitude: 78.0349)
                            default:
                                return CLLocationCoordinate2D(latitude: 31.1048, longitude: 77.1734)
                            }
                        }
                        
                        private func mockRoadAlertsFor(_ location: String) -> [RoadAlert] {
                            if location == "Manali" {
                                return [
                                    RoadAlert(
                                        road: "Rohtang Pass",
                                        description: "Road open from 8 AM to 4 PM. Permit required for vehicles.",
                                        status: .caution
                                    )
                                ]
                            } else if location == "Spiti Valley" {
                                return [
                                    RoadAlert(
                                        road: "Kunzum Pass",
                                        description: "Road closed due to recent snowfall. Expected to open in 2 days.",
                                        status: .closed
                                    ),
                                    RoadAlert(
                                        road: "Kaza-Losar Road",
                                        description: "Road open but expect rough patches due to recent landslides.",
                                        status: .caution
                                    )
                                ]
                            }
                            return []
                        }
                        
                        private func mockAttractionsFor(_ location: String) -> [Attraction] {
                            switch location {
                            case "Shimla":
                                return [
                                    Attraction(
                                        name: "The Ridge",
                                        description: "Large open space in the heart of Shimla with panoramic views of the surrounding mountains.",
                                        image: "shimla_ridge",
                                        bestTimeToVisit: "Evening",
                                        difficulty: nil
                                    ),
                                    Attraction(
                                        name: "Jakhu Temple",
                                        description: "Ancient temple dedicated to Lord Hanuman with a 108-feet tall statue.",
                                        image: "jakhu_temple",
                                        bestTimeToVisit: "Morning",
                                        difficulty: .moderate
                                    ),
                                    Attraction(
                                        name: "Mall Road",
                                        description: "The main street of Shimla with shops, restaurants, and colonial buildings.",
                                        image: "mall_road",
                                        bestTimeToVisit: "Afternoon",
                                        difficulty: nil
                                    )
                                ]
                            case "Manali":
                                return [
                                    Attraction(
                                        name: "Rohtang Pass",
                                        description: "High mountain pass with snow-capped peaks and breathtaking views.",
                                        image: "rohtang_pass",
                                        bestTimeToVisit: "7 AM - 12 PM",
                                        difficulty: .moderate
                                    ),
                                    Attraction(
                                        name: "Solang Valley",
                                        description: "Adventure sports hub with paragliding, zorbing, and skiing in winter.",
                                        image: "solang_valley",
                                        bestTimeToVisit: "Morning",
                                        difficulty: nil
                                    ),
                                    Attraction(
                                        name: "Hidimba Devi Temple",
                                        description: "Ancient wooden temple dedicated to Hidimba Devi in a cedar forest.",
                                        image: "hidimba_temple",
                                        bestTimeToVisit: "Anytime",
                                        difficulty: .easy
                                    )
                                ]
                            default:
                                return [
                                    Attraction(
                                        name: "Local Attraction",
                                        description: "A beautiful place to visit in this area.",
                                        image: "attraction_image",
                                        bestTimeToVisit: "Morning",
                                        difficulty: nil
                                    )
                                ]
                            }
                        }
                        
                        private func mockFoodRecommendationsFor(_ location: String) -> [FoodRecommendation] {
                            switch location {
                            case "Shimla":
                                return [
                                    FoodRecommendation(
                                        name: "Madra",
                                        description: "Traditional Himachali dish made with chickpeas cooked in yogurt gravy.",
                                        image: "madra_food",
                                        tags: ["Vegetarian", "Local", "Spicy"],
                                        bestPlace: "Himachali Rasoi"
                                    ),
                                    FoodRecommendation(
                                        name: "Sidu",
                                        description: "A type of bread stuffed with poppy seeds, served with ghee.",
                                        image: "sidu_food",
                                        tags: ["Vegetarian", "Breakfast"],
                                        bestPlace: "Ashiana Restaurant"
                                    )
                                ]
                            case "Manali":
                                return [
                                    FoodRecommendation(
                                        name: "Trout Fish",
                                        description: "Freshwater fish found in the rivers of Himachal, usually grilled or fried.",
                                        image: "trout_fish",
                                        tags: ["Non-Vegetarian", "Specialty"],
                                        bestPlace: "Johnson's Cafe"
                                    ),
                                    FoodRecommendation(
                                        name: "Tudkiya Bhath",
                                        description: "Traditional rice dish cooked with lentils and aromatic spices.",
                                        image: "tudkiya_bhath",
                                        tags: ["Vegetarian", "Lunch"],
                                        bestPlace: "Drifters Inn"
                                    )
                                ]
                            default:
                                return [
                                    FoodRecommendation(
                                        name: "Local Cuisine",
                                        description: "Traditional food of this region with authentic flavors.",
                                        image: "food_image",
                                        tags: ["Local", "Authentic"],
                                        bestPlace: "Local Restaurant"
                                    )
                                ]
                            }
                        }
                        
                        private func mockActivitiesFor(_ location: String) -> [Activity] {
                            switch location {
                            case "Shimla":
                                return [
                                    Activity(
                                        name: "Heritage Walk",
                                        description: "Explore colonial architecture and historical buildings around Mall Road and The Ridge.",
                                        icon: "figure.walk",
                                        difficulty: .easy,
                                        duration: "2-3 hours"
                                    ),
                                    Activity(
                                        name: "Toy Train Ride",
                                        description: "Experience the UNESCO World Heritage Kalka-Shimla railway journey.",
                                        icon: "tram.fill",
                                        difficulty: nil,
                                        duration: "5-6 hours"
                                    )
                                ]
                            case "Manali":
                                return [
                                    Activity(
                                        name: "River Rafting",
                                        description: "Experience white water rafting in the rapids of Beas River.",
                                        icon: "waterbottle",
                                        difficulty: .challenging,
                                        duration: "1-2 hours"
                                    ),
                                    Activity(
                                        name: "Paragliding",
                                        description: "Soar through the sky with a tandem paragliding experience in Solang Valley.",
                                        icon: "airplane",
                                        difficulty: .moderate,
                                        duration: "15-30 minutes"
                                    ),
                                    Activity(
                                        name: "Vashisht Hot Springs",
                                        description: "Relax in the natural hot water springs with therapeutic minerals.",
                                        icon: "drop.fill",
                                        difficulty: .easy,
                                        duration: "1 hour"
                                    )
                                ]
                            default:
                                return [
                                    Activity(
                                        name: "Local Activity",
                                        description: "An exciting activity to experience in this area.",
                                        icon: "figure.hiking",
                                        difficulty: .moderate,
                                        duration: "2 hours"
                                    )
                                ]
                            }
                        }
                    }

                    class UserProfileViewModel: ObservableObject {
                        let name = "Mountain Explorer"
                        let profileImage = "user_profile"
                        let totalVisits = 12
                        
                        @Published var collectedStamps: [PassportStamp] = []
                        @Published var journeys: [Journey] = []
                        @Published var contributions: [Contribution] = []
                        
                        init() {
                            loadMockData()
                        }
                        
                        private func loadMockData() {
                            // Mock passport stamps
                            collectedStamps = [
                                PassportStamp(location: "Shimla", icon: "🏔", date: Date().addingTimeInterval(-7776000)), // 90 days ago
                                PassportStamp(location: "Manali", icon: "❄️", date: Date().addingTimeInterval(-5184000)), // 60 days ago
                                PassportStamp(location: "Dharamshala", icon: "🧘", date: Date().addingTimeInterval(-2592000)), // 30 days ago
                                PassportStamp(location: "Dalhousie", icon: "⛰", date: Date().addingTimeInterval(-1296000)), // 15 days ago
                                PassportStamp(location: "McLeodganj", icon: "🙏", date: Date().addingTimeInterval(-864000)), // 10 days ago
                                PassportStamp(location: "Kasauli", icon: "🌲", date: Date().addingTimeInterval(-432000)) // 5 days ago
                            ]
                            
                            // Mock journeys
                            journeys = [
                                Journey(
                                    title: "Winter Wonderland",
                                    startDate: Date().addingTimeInterval(-7776000), // 90 days ago
                                    endDate: Date().addingTimeInterval(-7257600), // 84 days ago
                                    waypoints: ["Shimla", "Kufri", "Narkanda", "Chail"],
                                    status: .completed
                                ),
                                Journey(
                                    title: "Spiritual Retreat",
                                    startDate: Date().addingTimeInterval(-2592000), // 30 days ago
                                    endDate: Date().addingTimeInterval(-2160000), // 25 days ago
                                    waypoints: ["Dharamshala", "McLeodganj", "Triund", "Bhagsu"],
                                    status: .completed
                                ),
                                Journey(
                                    title: "Adventure Trail",
                                    startDate: Date().addingTimeInterval(1728000), // 20 days from now
                                    endDate: Date().addingTimeInterval(2160000), // 25 days from now
                                    waypoints: ["Manali", "Solang", "Rohtang Pass", "Sissu", "Keylong"],
                                    status: .upcoming
                                )
                            ]
                            
                            // Mock contributions
                            contributions = [
                                Contribution(
                                    location: "Triund Trek Summit",
                                    description: "Reached the top after a 4-hour trek. The view of Dhauladhar range is absolutely breathtaking!",
                                    image: "triund_contribution",
                                    date: Date().addingTimeInterval(-2332800) // 27 days ago
                                ),
                                Contribution(
                                    location: "Cafe at Old Manali",
                                    description: "Found this hidden gem with the best apple cinnamon pie and a view of the river.",
                                    image: "manali_cafe_contribution",
                                    date: Date().addingTimeInterval(-5011200) // 58 days ago
                                ),
                                Contribution(
                                    location: "Prashar Lake",
                                    description: "The lake is surrounded by snow-covered peaks. Go early to avoid crowds.",
                                    image: "prashar_lake_contribution",
                                    date: Date().addingTimeInterval(-4320000) // 50 days ago
                                )
                            ]
                        }
                    }

                    class LocationManager: ObservableObject {
                        @Published var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 31.1048, longitude: 77.1734) // Default to Shimla
                        
                        // In a real app, this would use CLLocationManager to get actual user location
                    }

                    // MARK: - Mock Data for Demo

                    let mockHiddenGems: [HiddenGem] = [
                        HiddenGem(
                            name: "Prashar Lake",
                            location: "Mandi",
                            image: "prashar_lake",
                            visitors: 127,
                            rating: 4.8
                        ),
                        HiddenGem(
                            name: "Malana Village",
                            location: "Parvati Valley",
                            image: "malana_village",
                            visitors: 89,
                            rating: 4.5
                        ),
                        HiddenGem(
                            name: "Chanshal Pass",
                            location: "Shimla",
                            image: "chanshal_pass",
                            visitors: 62,
                            rating: 4.7
                        ),
                        HiddenGem(
                            name: "Barot Valley",
                            location: "Mandi",
                            image: "barot_valley",
                            visitors: 107,
                            rating: 4.6
                        )
                    ]

                    let mockLocalGuides: [LocalGuide] = [
                        LocalGuide(
                            name: "Rahul Thakur",
                            profileImage: "guide_rahul",
                            specialty: ["Trekking", "Photography"],
                            languages: ["English", "Hindi", "German"],
                            rating: 4.9,
                            reviewCount: 127,
                            yearsExperience: 7,
                            regions: ["Manali", "Spiti Valley", "Lahaul"],
                            bio: "Born and raised in Manali, I've spent my life exploring the mountains of Himachal. I specialize in trekking routes and hidden spots for photography. I enjoy showing visitors the authentic Himachali culture and connecting them with local communities.",
                            reviews: [
                                Review(
                                    userName: "Alex Smith",
                                    userImage: "review_user1",
                                    rating: 5,
                                    date: Date().addingTimeInterval(-1296000),
                                    comment: "Rahul took us on an amazing trek to Hampta Pass. His knowledge of the area and photography tips made our trip exceptional."
                                ),
                                Review(
                                    userName: "Sophie Chen",
                                    userImage: "review_user2",
                                    rating: 5,
                                    date: Date().addingTimeInterval(-2592000),
                                    comment: "We had a wonderful experience with Rahul in Spiti Valley. He knows all the best spots and is very considerate of different fitness levels."
                                )
                            ]
                        ),
                        LocalGuide(
                            name: "Priya Sharma",
                            profileImage: "guide_priya",
                            specialty: ["Culture", "Food"],
                            languages: ["English", "Hindi", "French"],
                            rating: 4.8,
                            reviewCount: 98,
                            yearsExperience: 5,
                            regions: ["Shimla", "Dharamshala", "Kangra Valley"],
                            bio: "As a cultural enthusiast and foodie, I love sharing Himachal's rich traditions and cuisine. My tours focus on authentic experiences, from traditional Himachali cooking classes to meeting local artisans and exploring ancient temples.",
                            reviews: [
                                Review(
                                    userName: "Maria Gonzalez",
                                    userImage: "review_user3",
                                    rating: 5,
                                    date: Date().addingTimeInterval(-864000),
                                    comment: "Priya's food tour in Dharamshala was the highlight of our trip! We discovered incredible local dishes we would have never found on our own."
                                )
                            ]
                        ),
                        LocalGuide(
                            name: "Vikram Negi",
                            profileImage: "guide_vikram",
                            specialty: ["Adventure", "Wildlife"],
                            languages: ["English", "Hindi", "Spanish"],
                            rating: 4.7,
                            reviewCount: 84,
                            yearsExperience: 9,
                            regions: ["Dalhousie", "Chamba", "Great Himalayan National Park"],
                            bio: "Adventure enthusiast and certified wildlife expert. I organize rafting, paragliding, and wildlife safaris across Himachal Pradesh. My specialty is tracking wildlife in the Great Himalayan National Park while ensuring responsible tourism practices.",
                            reviews: []
                        ),
                        LocalGuide(
                            name: "Tenzin Dorje",
                            profileImage: "guide_tenzin",
                            specialty: ["Yoga", "Meditation"],
                            languages: ["English", "Hindi", "Tibetan", "Japanese"],
                            rating: 4.9,
                            reviewCount: 112,
                            yearsExperience: 6,
                            regions: ["McLeodganj", "Dharamshala", "Bir Billing"],
                            bio: "Born in Tibet and raised in Dharamshala, I offer authentic yoga and meditation retreats in the Himalayan foothills. My tours combine spiritual practices with visits to monasteries and meetings with Buddhist scholars.",
                            reviews: []
                        )
                    ]

                    let mockFestivals: [Festival] = [
                        Festival(
                            name: "Kullu Dussehra",
                            location: "Kullu",
                            image: "kullu_dussehra",
                            date: Date().addingTimeInterval(1296000), // 15 days from now
                            description: "A week-long celebration featuring processions of local deities, cultural performances, and crafts fair."
                        ),
                        Festival(
                            name: "Minjar Fair",
                            location: "Chamba",
                            image: "minjar_fair",
                            date: Date().addingTimeInterval(2592000), // 30 days from now
                            description: "Traditional fair celebrating the corn harvest season with folk dances, music, and ceremonial processions."
                        ),
                        Festival(
                            name: "Losar Festival",
                            location: "Spiti Valley",
                            image: "losar_festival",
                            date: Date().addingTimeInterval(4320000), // 50 days from now
                            description: "Tibetan New Year celebration with mask dances, monastery prayers, and traditional food."
                        )
                    ]

                    let mockCommunityStories: [CommunityStory] = [
                        CommunityStory(
                            title: "Finding Serenity at Chandratal Lake",
                            excerpt: "Our overnight camping experience at this crescent-shaped lake at 14,100 ft. The night sky was magical!",
                            image: "chandratal_story",
                            author: "Michael J.",
                            authorImage: "story_author1",
                            date: Date().addingTimeInterval(-1728000) // 20 days ago
                        ),
                        CommunityStory(
                            title: "The Hidden Cafes of Old Manali",
                            excerpt: "Discovered some amazing cafes tucked away in the lanes of Old Manali with stunning views and great food.",
                            image: "manali_cafes_story",
                            author: "Emma L.",
                            authorImage: "story_author2",
                            date: Date().addingTimeInterval(-2592000) // 30 days ago
                        ),
                        CommunityStory(
                            title: "Trekking to Triund: A Beginner's Guide",
                            excerpt: "My experience hiking to Triund, what to pack, where to rest, and how to prepare for your first Himalayan trek.",
                            image: "triund_story",
                            author: "Raj S.",
                            authorImage: "story_author3",
                            date: Date().addingTimeInterval(-3456000) // 40 days ago
                        )
                    ]



#Preview {
    ContentView()
}
