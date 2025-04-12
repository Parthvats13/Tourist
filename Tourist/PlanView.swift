import SwiftUI
import CoreLocation

// MARK: - Plan Tab View

struct PlanView: View {
    @EnvironmentObject private var tripPlanner: TripPlannerViewModel
    @State private var startDestination = ""
    @State private var endDestination = ""
    @State private var startDate = Date()
    @State private var endDate: Date
    @State private var selectedInterests: Set<TravelInterest> = []
    @State private var showItinerary = false
    
    // Initialize endDate based on initial startDate
    init() {
        _endDate = State(initialValue: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date())
    }
    
    var isFormValid: Bool {
        !startDestination.isEmpty && !endDestination.isEmpty && !selectedInterests.isEmpty && endDate >= startDate
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Header Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("himachal_background")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .cornerRadius(15)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Plan Your Himachal Adventure")
                                .font(.title2).bold()
                                .foregroundColor(.white)
                            
                            Text("Create a personalized journey through the mountains")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Destinations Section
                    PlanSectionHeader(title: "Where To?", icon: "map.fill")
                    
                    VStack(spacing: 12) {
                        PlanTextFieldCard(
                            iconName: "mappin.circle.fill",
                            placeholder: "Starting Point (e.g., Shimla)",
                            text: $startDestination
                        )
                        
                        PlanTextFieldCard(
                            iconName: "mappin.and.ellipse",
                            placeholder: "Final Destination (e.g., Manali)",
                            text: $endDestination
                        )
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Travel Dates Section
                    PlanSectionHeader(title: "When?", icon: "calendar")
                    
                    VStack(spacing: 12) {
                        DatePickerCard(title: "Start Date", selection: $startDate)
                        DatePickerCard(title: "End Date", selection: $endDate, minDate: startDate)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Interest Section with Horizontal Scrolling Chips
                    PlanSectionHeader(title: "Your Interests", icon: "heart.fill")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(TravelInterest.allCases) { interest in
                                InterestChip(
                                    interest: interest,
                                    isSelected: selectedInterests.contains(interest),
                                    toggleAction: {
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
                        .padding(.vertical, 8)
                    }
                    
                    // MARK: - Generate Button
                    VStack {
                        Button {
                            hideKeyboard()
                            if isFormValid {
                                tripPlanner.generateItinerary(
                                    startDestination: startDestination,
                                    endDestination: endDestination,
                                    startDate: startDate,
                                    endDate: endDate,
                                    interests: Array(selectedInterests)
                                )
                                showItinerary = true
                            }
                        } label: {
                            HStack(spacing: 12) {
                                if tripPlanner.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                        .font(.headline)
                                }
                                Text("Generate My Yatra")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(.indigo)
                        .disabled(!isFormValid || tripPlanner.isLoading)
                        .padding(.horizontal)
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                        
                        if let errorMessage = tripPlanner.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .padding(.top, 15)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Plan Your Trip")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "mountain.2.fill")
                        .foregroundColor(.indigo)
                }
            }
            .navigationDestination(isPresented: $showItinerary) {
                ItineraryView()
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

// MARK: - Supporting Views for Plan Page

struct PlanSectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.indigo)
                .imageScale(.medium)
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding(.horizontal)
        .padding(.top, 5)
    }
}

struct PlanTextFieldCard: View {
    let iconName: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(.indigo)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .padding(.vertical, 12)
        }
        .padding(.horizontal, 16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct DatePickerCard: View {
    let title: String
    @Binding var selection: Date
    var minDate: Date?
    
    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(.indigo)
                .frame(width: 24)
            
            if let minDate = minDate {
                DatePicker(title, selection: $selection, in: minDate..., displayedComponents: .date)
                    .padding(.vertical, 10)
            } else {
                DatePicker(title, selection: $selection, displayedComponents: .date)
                    .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Interest Chip View (Horizontally Scrolling)

struct InterestChip: View {
    let interest: TravelInterest
    let isSelected: Bool
    let toggleAction: () -> Void
    
    var body: some View {
        Button(action: toggleAction) {
            HStack(spacing: 6) {
                Image(systemName: interest.icon)
                    .foregroundColor(isSelected ? .white : .indigo)
                    .imageScale(.small)
                
                Text(interest.rawValue.capitalized)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Color.indigo : Color(UIColor.secondarySystemGroupedBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(isSelected ? Color.indigo : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color.indigo.opacity(0.3) : Color.clear, radius: 3, x: 0, y: 1)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Add subtle scale animation to chips
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Itinerary List View

struct ItineraryView: View {
    @EnvironmentObject private var tripPlanner: TripPlannerViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Journey Overview Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Himachal Journey")
                        .font(.title2).bold()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.indigo)
                                    .imageScale(.small)
                                
                                Text("From:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(tripPlanner.startDestination ?? "N/A")
                                    .font(.subheadline).bold()
                            }
                            
                            HStack {
                                Image(systemName: "location.circle.fill")
                                    .foregroundColor(.indigo)
                                    .imageScale(.small)
                                
                                Text("To:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(tripPlanner.endDestination ?? "N/A")
                                    .font(.subheadline).bold()
                            }
                        }
                        
                        Spacer()
                        
                        if let start = tripPlanner.startDate, let end = tripPlanner.endDate {
                            VStack(alignment: .trailing, spacing: 4) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.indigo)
                                        .imageScale(.small)
                                    
                                    Text(start.formatted(date: .abbreviated, time: .omitted))
                                        .font(.subheadline)
                                }
                                
                                HStack {
                                    Image(systemName: "calendar.badge.clock")
                                        .foregroundColor(.indigo)
                                        .imageScale(.small)
                                    
                                    Text(end.formatted(date: .abbreviated, time: .omitted))
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    
                    if let start = tripPlanner.startDate, let end = tripPlanner.endDate {
                        let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
                        
                        HStack {
                            Label("\(days + 1) Days", systemImage: "clock.fill")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.indigo.opacity(0.1))
                                .cornerRadius(8)
                            
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Itinerary Days Section
                if tripPlanner.isLoading {
                    LoadingView(message: "Generating Itinerary...")
                } else if tripPlanner.itineraryDays.isEmpty {
                    EmptyStateView(message: "No itinerary generated yet. Please go back and provide your trip details.")
                } else {
                    Text("Daily Itinerary")
                        .font(.title3).bold()
                        .padding(.horizontal)
                        .padding(.top, 5)
                    
                    VStack(spacing: 16) {
                        ForEach(Array(tripPlanner.itineraryDays.enumerated()), id: \.element.id) { index, day in
                            NavigationLink {
                                ItineraryDayDetailView(day: day, dayNumber: index + 1)
                            } label: {
                                ItineraryDayCard(day: day, dayNumber: index + 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Your Itinerary")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Keep the dummy data fetch for testing if needed
#if DEBUG
            if tripPlanner.itineraryDays.isEmpty && !tripPlanner.isLoading {
                print("DEBUG: Fetching dummy itinerary.")
                tripPlanner.fetchDummyItinerary()
            }
#endif
        }
    }
}

// MARK: - Supporting Views for Itinerary

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}

struct EmptyStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "map")
                .font(.system(size: 50))
                .foregroundColor(.indigo.opacity(0.6))
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}

struct ItineraryDayCard: View {
    let day: ItineraryDay
    let dayNumber: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image with header overlay
            ZStack(alignment: .bottomLeading) {
                Image(day.mainImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                // Gradient overlay for better text visibility
                LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                // Day badge and location
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Day \(dayNumber)")
                            .font(.caption).bold()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color.blue))
                            .foregroundColor(.white)
                        
                        Text("•")
                            .foregroundColor(.white)
                        
                        Text(day.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption).bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if day.hasWeatherAlert {
                            Image(systemName: day.weatherAlert?.icon ?? "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .padding(8)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                    }
                    
                    Text(day.mainLocation)
                        .font(.title3).bold()
                        .foregroundColor(.white)
                        .shadow(radius: 1)
                }
                .padding(12)
            }
            
            // Highlights
            VStack(alignment: .leading, spacing: 8) {
                Text("Highlights")
                    .font(.headline)
                    .foregroundColor(.indigo)
                
                ForEach(day.highlights.prefix(3), id: \.self) { highlight in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.small)
                            .padding(.top, 2)
                        
                        Text(highlight)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                }
                
                if day.highlights.count > 3 {
                    Text("+ \(day.highlights.count - 3) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 24)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Itinerary Day Detail View

struct ItineraryDayDetailView: View {
    let day: ItineraryDay
    let dayNumber: Int
    @State private var selectedSection: ItinerarySection = .attractions
    
    enum ItinerarySection: String, CaseIterable, Identifiable {
        case attractions = "Attractions"
        case food = "Food"
        case activities = "Activities"
        case alerts = "Alerts"
        case notes = "Notes"
        
        var id: String { self.rawValue }
        
        var systemImage: String {
            switch self {
            case .attractions: "mappin.and.ellipse"
            case .food: "fork.knife"
            case .activities: "figure.walk"
            case .alerts: "exclamationmark.triangle.fill"
            case .notes: "note.text"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image with Overlay
                ZStack(alignment: .bottom) {
                    Image(day.mainImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                    
                    // Gradient overlay for better text visibility
                    LinearGradient(
                        gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                        startPoint: .bottom,
                        endPoint: .center
                    )
                    .frame(height: 120)
                    
                    // Location and Date
                    VStack(alignment: .leading, spacing: 5) {
                        Text(day.mainLocation)
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                        
                        HStack {
                            Text(day.date.formatted(date: .long, time: .omitted))
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(radius: 1)
                            
                            if let altitude = day.altitude {
                                Text("•")
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Label("\(altitude)m", systemImage: "mountain.2.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                    .shadow(radius: 1)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                }
                
                // Map Snippet
                MapSnippet(location: day.locationCoordinate, locationName: day.mainLocation)
                    .frame(height: 180)
                    .cornerRadius(15)
                    .padding(.horizontal)
                
                // Section Picker
                Picker("Details", selection: $selectedSection) {
                    ForEach(ItinerarySection.allCases) { section in
                        Label(section.rawValue, systemImage: section.systemImage)
                            .tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Section Content
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: selectedSection.systemImage)
                            .foregroundColor(.indigo)
                        
                        Text(selectedSection.rawValue)
                            .font(.title2).bold()
                    }
                    .padding(.bottom, 10)
                    
                    switch selectedSection {
                    case .attractions:
                        AttractionsSection(attractions: day.attractions)
                    case .food:
                        FoodSection(recommendations: day.foodRecommendations)
                    case .activities:
                        ActivitiesSection(activities: day.activities)
                    case .alerts:
                        AlertsSection(weatherAlert: day.weatherAlert, roadAlerts: day.roadAlerts)
                    case .notes:
                        NotesSection(dayId: day.id)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
        }
        .navigationTitle("Day \(dayNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Edit/Customize day functionality
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Detail View Sub-Sections

struct MapSnippet: View {
    let location: CLLocationCoordinate2D
    let locationName: String
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.3), .green.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack {
                Image(systemName: "map.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 5)
                
                Text(locationName)
                    .font(.headline)
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                
                Text("(\(String(format: "%.3f", location.latitude)), \(String(format: "%.3f", location.longitude)))")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(radius: 1)
            }
            .padding()
        }
    }
}

// MARK: - Section Content Views

struct AttractionsSection: View {
    let attractions: [Attraction]
    
    var body: some View {
        if attractions.isEmpty {
            Text("No specific attractions listed for this day.")
                .foregroundColor(.secondary)
                .padding(.vertical)
        } else {
            VStack(alignment: .leading, spacing: 18) {
                ForEach(attractions) { attraction in
                    AttractionRow(attraction: attraction)
                    
                    if attraction.id != attractions.last?.id {
                        Divider()
                            .padding(.leading, 95)
                    }
                }
            }
        }
    }
}

struct AttractionRow: View {
    let attraction: Attraction
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(attraction.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(10)
                .clipped()
            
            VStack(alignment: .leading, spacing: 5) {
                Text(attraction.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(attraction.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 15) {
                    Label(attraction.bestTimeToVisit, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let difficulty = attraction.difficulty {
                        Label(difficulty.rawValue, systemImage: "figure.hiking")
                            .font(.caption)
                            .foregroundColor(difficulty.color)
                    }
                }
                .padding(.top, 2)
            }
            
            Spacer()
        }
    }
}

struct FoodSection: View {
    let recommendations: [FoodRecommendation]
    
    var body: some View {
        if recommendations.isEmpty {
            Text("No specific food recommendations for this day.")
                .foregroundColor(.secondary)
                .padding(.vertical)
        } else {
            VStack(alignment: .leading, spacing: 18) {
                ForEach(recommendations) { food in
                    FoodRow(food: food)
                    
                    if food.id != recommendations.last?.id {
                        Divider()
                            .padding(.leading, 95)
                    }
                }
            }
        }
    }
}

struct FoodRow: View {
    let food: FoodRecommendation
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(food.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(10)
                .clipped()
            
            VStack(alignment: .leading, spacing: 5) {
                Text(food.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(food.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if !food.tags.isEmpty {
                    HStack {
                        ForEach(food.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.green.opacity(0.2)))
                                .foregroundColor(.green.opacity(0.9))
                        }
                    }
                    .padding(.top, 2)
                }
                
                if let place = food.bestPlace {
                    Label("Try at: \(place)", systemImage: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
        }
    }
}

struct ActivitiesSection: View {
    let activities: [Activity]
    
    var body: some View {
        if activities.isEmpty {
            Text("No specific activities listed for this day.")
                .foregroundColor(.secondary)
                .padding(.vertical)
        } else {
            VStack(alignment: .leading, spacing: 15) {
                ForEach(activities) { activity in
                    ActivityCard(activity: activity)
                }
            }
        }
    }
}

struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: activity.icon)
                    .font(.title3)
                    .foregroundColor(.indigo)
                    .frame(width: 30, alignment: .center)
                
                Text(activity.name)
                    .font(.headline)
                
                Spacer()
                
                if let difficulty = activity.difficulty {
                    DifficultyBadge(difficulty: difficulty)
                }
            }
            
            Text(activity.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let duration = activity.duration {
                Label("Duration: \(duration)", systemImage: "hourglass")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding()
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct DifficultyBadge: View {
    let difficulty: Difficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption).bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(difficulty.color.opacity(0.15))
            .foregroundColor(difficulty.color)
            .clipShape(Capsule())
    }
}

struct AlertsSection: View {
    let weatherAlert: WeatherAlert?
    let roadAlerts: [RoadAlert]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if weatherAlert == nil && roadAlerts.isEmpty {
                Label("No travel advisories reported for this area.", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(.vertical)
            } else {
                if let alert = weatherAlert {
                    AlertCard(
                        title: alert.type,
                        description: alert.description,
                        icon: alert.icon,
                        color: .orange
                    )
                }
                
                ForEach(roadAlerts) { alert in
                    AlertCard(
                        title: "Road: \(alert.road) (\(alert.status.rawValue))",
                        description: alert.description,
                        icon: alert.status.icon,
                        color: alert.status.color
                    )
                }
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
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30, alignment: .center)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.3), lineWidth: 1))
    }
}

struct NotesSection: View {
    let dayId: String
    @State private var note: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            TextEditor(text: $note)
                .frame(minHeight: 150, maxHeight: 300)
                .padding(8)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .font(.body)
            
            Button {
                hideKeyboard()
                // Save note implementation would go here
            } label: {
                Label("Save Note", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.bordered)
            .tint(.indigo)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

// MARK: - Keyboard Helper

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
