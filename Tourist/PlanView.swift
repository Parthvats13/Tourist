import SwiftUI
import CoreLocation // Keep this import

// MARK: - Plan Tab View

struct PlanView: View {
    @EnvironmentObject private var tripPlanner: TripPlannerViewModel
    @State private var startDestination = ""
    @State private var endDestination = ""
    @State private var startDate = Date()
    // Ensure end date is always after start date
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
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) { // Use spacing 0 and add padding manually for control
                        // Header Section
                        VStack {
                            Text("Plan Your Himachal Journey")
                                .font(.largeTitle).bold()
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary) // Use primary color
                                .padding(.top, 30)
                            
                            Text("Customize your perfect adventure")
                                .font(.headline) // Slightly larger subheadline
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 20)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity) // Ensure centering
                        
                        // Form Section
                        Form {
                            Section("Destinations") {
                                TextField("Starting Point (e.g., Shimla)", text: $startDestination)
                                TextField("Final Destination (e.g., Manali)", text: $endDestination)
                            }
                            
                            Section("Travel Dates") {
                                // Use minDate for End Date picker correctly
                                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                            }
                            
                            Section("Your Interests") {
                                InterestSelector(selectedInterests: $selectedInterests)
                                    .padding(.vertical, 5) // Add padding within the form row
                            }
                        }
                        // Adjust form style for better integration if needed
                        // .formStyle(.grouped) // Or .plain
                        .frame(height: calculateFormHeight()) // Adjust height dynamically or set a fixed suitable height
                        .scrollDisabled(true) // Disable Form's internal scroll
                        
                        // Generate Button
                        Button {
                            hideKeyboard() // Ensure keyboard dismisses
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
                            HStack {
                                if tripPlanner.isLoading {
                                    ProgressView()
                                        .tint(.white) // Make spinner white
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                Text("Generate My Yatra")
                                    .fontWeight(.semibold)
                            }
                        }
                        .buttonStyle(.borderedProminent) // Use prominent style
                        .tint(.indigo) // Consistent accent color
                        .controlSize(.large) // Make button larger
                        .disabled(!isFormValid || tripPlanner.isLoading) // Disable based on validation
                        .padding(.horizontal)
                        .padding(.top, 20) // Add space above the button
                        
                        // Error Message Display
                        if let errorMessage = tripPlanner.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                        
                        Spacer(minLength: 20) // Ensure space at the bottom
                    }
                    // Use minHeight to allow shrinking on small screens but expansion otherwise
                    .frame(minHeight: geometry.size.height)
                }
                // Add background AFTER the ScrollView
                .background(
                    Image("himachal_background") // Choose a less distracting background
                        .resizable()
                        .scaledToFill()
                        .overlay(.thinMaterial) // Use material blur for better readability
                        .ignoresSafeArea()
                )
                .navigationTitle("Plan Your Trip")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image(systemName: "mountain.2.fill")
                            .foregroundColor(.indigo) // Match accent color
                    }
                }
                .navigationDestination(isPresented: $showItinerary) {
                    ItineraryView()
                }
            }
            .onTapGesture { // Dismiss keyboard on tap outside form
                hideKeyboard()
            }
        }
    }
}
    
    
    
    
    // Helper to calculate approximate form height
    // Adjust numbers based on testing with actual content
    private func calculateFormHeight() -> CGFloat {
        // Break down the calculation into separate variables
        let baseHeight: CGFloat = 80
        let destinationFieldsHeight: CGFloat = 44 * 2
        let datePickersHeight: CGFloat = 44 * 2
        let interestsHeight: CGFloat = 80
        
        // Sum all the components
        return baseHeight + destinationFieldsHeight + datePickersHeight + interestsHeight
    }

    // MARK: - Interest Selector and Chip
    
    struct InterestSelector: View {
        @Binding var selectedInterests: Set<TravelInterest>
        let allInterests: [TravelInterest] = TravelInterest.allCases
        
        // Use adaptive columns for better layout on different screen sizes
        private let columns = [GridItem(.adaptive(minimum: 120))]
        
        var body: some View {
            // Use LazyVGrid for wrapping effect if needed, or ScrollView for horizontal list
            // ScrollView is often better for a limited number of items
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(allInterests) { interest in
                        InterestChip(
                            interest: interest,
                            isSelected: selectedInterests.contains(interest)
                        ) {
                            if selectedInterests.contains(interest) {
                                selectedInterests.remove(interest)
                            } else {
                                selectedInterests.insert(interest)
                            }
                        }
                    }
                }
                .padding(.horizontal, -5) // Adjust padding if needed within Form
            }
        }
    }
    
    struct InterestChip: View {
        let interest: TravelInterest
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Label(interest.rawValue.capitalized, systemImage: interest.icon)
                    .font(.caption) // Use smaller font for chips
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundColor(isSelected ? .white : .accentColor) // Use accent color
                    .background(isSelected ? Color.accentColor : Color.accentColor.opacity(0.15)) // Use accent with opacity
                    .clipShape(Capsule())
            }
            // Add a subtle animation
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
    }
    
    
    // MARK: - Itinerary List View
    
    struct ItineraryView: View {
        @EnvironmentObject private var tripPlanner: TripPlannerViewModel
        
        var body: some View {
            // Use List for standard iOS look and feel
            List {
                // Header Section within the List
                Section {
                    VStack(alignment: .leading) {
                        Text("Your Himachal Journey")
                            .font(.title).bold()
                        
                        Text("From: \(tripPlanner.startDestination ?? "N/A") to \(tripPlanner.endDestination ?? "N/A")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 2)
                        
                        if let start = tripPlanner.startDate, let end = tripPlanner.endDate {
                            Text("\(start.formatted(date: .long, time: .omitted)) – \(end.formatted(date: .long, time: .omitted))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5) // Add padding inside the header
                }
                
                // Itinerary Days Section
                if tripPlanner.isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView("Generating Itinerary...")
                            Spacer()
                        }
                        .padding(.vertical, 40)
                    }
                } else if tripPlanner.itineraryDays.isEmpty {
                    Section {
                        Text("No itinerary generated yet. Please go back and provide your trip details.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 40)
                    }
                } else {
                    // Use indices for Day number
                    ForEach(Array(tripPlanner.itineraryDays.enumerated()), id: \.element.id) { index, day in
                        // Use NavigationLink directly on the row content
                        NavigationLink {
                            ItineraryDayDetailView(day: day, dayNumber: index + 1)
                        } label: {
                            // Embed the card content directly
                            ItineraryDayRow(day: day, dayNumber: index + 1)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)) // Customize row padding
                    .listRowSeparator(.hidden) // Hide default separators if using cards
                    .listRowBackground(Color.clear) // Make background transparent for cards
                }
            }
            .listStyle(.plain) // Use plain style for custom card look
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
            // Add a background to the List if needed
            // .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }
    
    // MARK: - Itinerary Day Row (Used in List)
    
    struct ItineraryDayRow: View {
        let day: ItineraryDay
        let dayNumber: Int
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Day \(dayNumber)")
                        .font(.headline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.blue.opacity(0.8))) // Slightly softer blue
                        .foregroundColor(.white)
                    
                    Text(day.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if day.hasWeatherAlert {
                        Image(systemName: day.weatherAlert?.icon ?? "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                Text(day.mainLocation)
                    .font(.title3).fontWeight(.semibold) // Slightly smaller title for row
                
                // Image with aspect ratio and corner radius
                Image(day.mainImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180) // Slightly taller image
                    .clipShape(RoundedRectangle(cornerRadius: 12)) // Consistent corner radius
                    .overlay( // Add a subtle gradient for text protection if needed
                        LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.4)]),
                                       startPoint: .center, endPoint: .bottom)
                    )
                    .cornerRadius(12) // Ensure gradient respects corner radius
                
                
                // Highlights using Label for icon + text
                VStack(alignment: .leading, spacing: 5) {
                    Text("Highlights:")
                        .font(.caption).fontWeight(.medium).foregroundColor(.secondary)
                        .padding(.bottom, 2)
                    
                    // Show only a few highlights, use vertical layout for better space usage
                    ForEach(day.highlights.prefix(3), id: \.self) { highlight in
                        Label(highlight, systemImage: "arrow.right.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                    if day.highlights.count > 3 {
                        Text("+ \(day.highlights.count - 3) more")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                }
            }
            .padding() // Add padding around the card content
            .background(Color(UIColor.secondarySystemGroupedBackground)) // Use system color for card background
            .cornerRadius(15) // Consistent corner radius
            .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2) // Softer shadow
        }
    }
    
    
    // MARK: - Itinerary Day Detail View
    
    struct ItineraryDayDetailView: View {
        let day: ItineraryDay
        let dayNumber: Int // Pass dayNumber for the title
        @State private var selectedSection: ItinerarySection = .attractions // Use enum for sections
        
        // Define sections using an Enum for type safety and clarity
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
                    // Header Image
                    Image(day.mainImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250) // Taller header image
                        .clipped()
                    // Optional: Add overlay gradient
                        .overlay(LinearGradient(gradient: Gradient(colors: [.black.opacity(0.5), .clear]), startPoint: .top, endPoint: .center))
                    
                    
                    // Location Info Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text(day.mainLocation)
                            .font(.largeTitle).bold()
                        
                        Text(day.date.formatted(date: .long, time: .omitted))
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if let altitude = day.altitude {
                            Label("Altitude: \(altitude)m", systemImage: "mountain.2.fill")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Map Snippet (Improved Placeholder)
                    MapSnippet(location: day.locationCoordinate, locationName: day.mainLocation)
                        .frame(height: 180)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    
                    // Section Picker using Segmented Control
                    Picker("Details", selection: $selectedSection) {
                        ForEach(ItinerarySection.allCases) { section in
                            // Use Label for icon + text in picker
                            Label(section.rawValue, systemImage: section.systemImage)
                                .tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Section Content - Grouped in a styled container
                    VStack(alignment: .leading) {
                        // Title for the selected section
                        Text(selectedSection.rawValue)
                            .font(.title2).bold()
                            .padding(.bottom, 5)
                        
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
                    
                    Spacer(minLength: 20) // Bottom padding
                }
            }
            .navigationTitle("Day \(dayNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Edit/Customize day functionality
                    } label: {
                        Label("Edit", systemImage: "pencil") // Use icon
                    }
                }
            }
            // Optional: Background for the whole ScrollView
            // .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }
    
    // MARK: - Detail View Sub-Sections (Attractions, Food, Activities, etc.)
    
    struct MapSnippet: View {
        let location: CLLocationCoordinate2D
        let locationName: String
        
        var body: some View {
            // Replace with actual MapKit View later
            ZStack {
                // Placeholder with a slightly more map-like feel
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .green.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                
                VStack {
                    Image(systemName: "map.fill")
                        .font(.largeTitle)
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
            .cornerRadius(15) // Ensure ZStack respects corner radius if needed elsewhere
        }
    }
    
    // MARK: - Section Content Views
    
    struct AttractionsSection: View {
        let attractions: [Attraction]
        
        var body: some View {
            // Check if attractions exist
            if attractions.isEmpty {
                Text("No specific attractions listed for this day.")
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                // Use VStack for vertical layout
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(attractions) { attraction in
                        AttractionRow(attraction: attraction)
                        // Add a separator if needed
                        if attraction.id != attractions.last?.id {
                            Divider()
                                .padding(.leading, 95) // Indent divider
                        }
                    }
                }
            }
        }
    }
    
    struct AttractionRow: View {
        let attraction: Attraction
        // Could add @State var isVisited: Bool = false for toggling
        
        var body: some View {
            HStack(alignment: .top, spacing: 15) {
                Image(attraction.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80) // Square image
                    .cornerRadius(10)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(attraction.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(attraction.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2) // Limit description length
                    
                    HStack(spacing: 15) {
                        Label(attraction.bestTimeToVisit, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let difficulty = attraction.difficulty {
                            Label(difficulty.rawValue, systemImage: "figure.hiking")
                                .font(.caption)
                                .foregroundColor(difficulty.color) // Use difficulty color
                        }
                    }
                    .padding(.top, 2)
                }
                Spacer() // Pushes content to left
                
                // Optional: Add a visited toggle or button
                // Toggle("", isOn: $isVisited)
                //     .labelsHidden()
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
                                .padding(.leading, 95) // Indent divider
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
                    
                    // Tags using capsules
                    if !food.tags.isEmpty {
                        HStack {
                            ForEach(food.tags.prefix(3), id: \.self) { tag in // Limit tags displayed
                                Text(tag)
                                    .font(.caption2) // Smaller font for tags
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
                // Use VStack for layout, potentially with cards for each activity
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
                        .font(.title3) // Slightly larger icon
                        .foregroundColor(.accentColor) // Use accent color
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
                    Label("Duration: \(duration)", systemImage: "hourglass") // Use hourglass icon
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
            .padding()
            .background(Color(UIColor.tertiarySystemGroupedBackground)) // Use tertiary for card-in-card
            .cornerRadius(12) // Slightly smaller radius for inner card
        }
    }
    
    struct DifficultyBadge: View {
        let difficulty: Difficulty
        
        var body: some View {
            Text(difficulty.rawValue)
                .font(.caption).bold()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(difficulty.color.opacity(0.15)) // Use color with opacity
                .foregroundColor(difficulty.color) // Use the difficulty color
                .clipShape(Capsule())
        }
    }
    
    struct AlertsSection: View {
        let weatherAlert: WeatherAlert?
        let roadAlerts: [RoadAlert]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                if weatherAlert == nil && roadAlerts.isEmpty {
                    // Use Label for positive indication
                    Label("No travel advisories reported for this area.", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(.vertical)
                } else {
                    if let alert = weatherAlert {
                        AlertCard(
                            title: alert.type, // Use type as title
                            description: alert.description,
                            icon: alert.icon,
                            color: .orange
                        )
                    }
                    
                    ForEach(roadAlerts) { alert in
                        AlertCard(
                            title: "Road: \(alert.road) (\(alert.status.rawValue))", // Include status in title
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
                        .foregroundColor(color) // Use color for title too
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.primary) // Use primary for description readability
                }
                Spacer() // Ensure left alignment
            }
            .padding()
            .background(color.opacity(0.1)) // Use background tint
            .cornerRadius(12)
            // Add border for more definition
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.3), lineWidth: 1))
        }
    }
    
    struct NotesSection: View {
        let dayId: String // Used to identify which day's note to save/load
        // TODO: Implement loading/saving logic using dayId (e.g., via @AppStorage or ViewModel)
        @State private var note: String = "" // Load initial note based on dayId
        
        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                TextEditor(text: $note)
                    .frame(minHeight: 150, maxHeight: 300) // Control height
                    .padding(8) // Padding inside the editor
                    .background(Color(UIColor.tertiarySystemBackground)) // Background color
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1)) // Border
                    .font(.body) // Standard body font
                
                Button {
                    // Save note functionality
                    // Example: saveNote(forDay: dayId, content: note)
                    hideKeyboard()
                } label: {
                    Label("Save Note", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.bordered) // Standard bordered button
                .tint(.accentColor) // Use accent color
                .frame(maxWidth: .infinity, alignment: .trailing) // Align button
            }
            .onAppear {
                // Load note when the view appears
                // Example: note = loadNote(forDay: dayId)
            }
        }
    }
    
    // MARK: - Keyboard Helper
    
    extension View {
        func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }



