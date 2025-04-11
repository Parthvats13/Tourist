import SwiftUI
import CoreLocation

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
                                    if tripPlanner.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 5)
                                    } else {
                                        Image(systemName: "sparkles")
                                    }
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
                            .disabled(startDestination.isEmpty || endDestination.isEmpty || selectedInterests.isEmpty || tripPlanner.isLoading)
                            .opacity((startDestination.isEmpty || endDestination.isEmpty || selectedInterests.isEmpty) ? 0.6 : 1)
                            
                            if let errorMessage = tripPlanner.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.horizontal, 16)
                            }
                            
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

// Extension to hide keyboard
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
                
                if tripPlanner.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Generating your personalized itinerary...")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 50)
                } else if tripPlanner.itineraryDays.isEmpty {
                    VStack(spacing: 20) {
                        Text("No itinerary data available")
                            .foregroundColor(.secondary)
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
                            if tripPlanner.itineraryDays.isEmpty && !tripPlanner.isLoading {
                                // If there's no data, fetch some dummy data for testing
                                tripPlanner.fetchDummyItinerary()
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
