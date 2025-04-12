import SwiftUI

// MARK: - Global Profile Details
struct ProfileDetails {
    static var username: String = UserProfileViewModel().name  // Default value will be set when profile loads
    static var contact: String = ""
    static var gender: String = ""
    static var nationality: String = ""
    static var domicile: String = ""
}

// MARK: - Passport Tab View

struct PassportView: View {
    @EnvironmentObject private var userProfile: UserProfileViewModel
    @State private var showingProfileSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                // Loading and Error States
                if userProfile.isLoading {
                    loadingView
                } else if let errorMessage = userProfile.errorMessage {
                    errorView(message: errorMessage)
                } else {
                    // Profile Content
                    VStack(spacing: 20) {
                        // Profile Header
                        profileHeader
                            .listRowInsets(EdgeInsets())

                        // Himachal Passport Section
                        passportSection

                        // My Journeys Section
                        journeysSection

                        // My Contributions Section
                        contributionsSection

                        // Action Buttons Section
                        actionButtons
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("My HimYatra")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await userProfile.asyncLoadUserProfile()
            }
            .background(Color(UIColor.secondarySystemBackground))
        }
        .background(Color(UIColor.secondarySystemBackground))
        .ignoresSafeArea(.all, edges: .bottom)
    }

    // MARK: - Subviews for Sections
    private var profileHeader: some View {
        VStack(spacing: 20) {
            // Main Profile Card
            Button(action: { showingProfileSheet = true }) {
                HStack(spacing: 15) {
                    Image(userProfile.profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text(userProfile.name)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)

                        Text("\(userProfile.totalVisits) Places Visited")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding()
                .background(Color(UIColor.systemBackground))  // White background for the card
                .cornerRadius(12)
                // Set username when profile loads
                .onAppear {
                    ProfileDetails.username = userProfile.name
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingProfileSheet) {
            ProfileDetailsSheet()
        }
    }

    private var passportSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Himachal Passport")
                .font(.title2).bold()
                .padding(.horizontal)

            // Passport view with constraints
            HimachalPassportView(stamps: userProfile.collectedStamps)
                .frame(height: 250) // Adjust height as needed
                 .padding(.horizontal)
                 // Add a subtle border/background if needed
                 .background(
                     RoundedRectangle(cornerRadius: 20)
                         .fill(Color.blue.opacity(0.05)) // Very light blue background
                         .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
                 )
                 .padding(.horizontal) // Padding around the background
        }
    }

    private var journeysSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("My Journeys")
                .font(.title2).bold()
                .padding(.horizontal)

            if userProfile.journeys.isEmpty {
                Text("You haven't planned any journeys yet. Start planning from the 'Plan' tab!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else {
                 // Use vertical stack for journeys
                VStack(spacing: 12) {
                    ForEach(userProfile.journeys) { journey in
                         NavigationLink {
                             // Destination: Journey Detail View (e.g., showing its itinerary)
                              // You might need to fetch the full itinerary for this journey ID
                             Text("Detail for Journey: \(journey.title)")
                         } label: {
                             JourneyCard(journey: journey)
                         }
                         .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

     private var contributionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("My Contributions")
                .font(.title2).bold()
                .padding(.horizontal)

             if userProfile.contributions.isEmpty {
                Text("Share your experiences from the 'Map' tab to see them here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                     .multilineTextAlignment(.center)
                     .padding()
                     .frame(maxWidth: .infinity)
                     .background(Color(UIColor.secondarySystemGroupedBackground))
                     .cornerRadius(12)
                     .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(userProfile.contributions) { contribution in
                            // Contributions might not need a detail view, or could show larger image/text
                            ContributionCard(contribution: contribution)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Share Profile/Journey Button
            Button {
                // Share Action
            } label: {
                Label("Share My Passport", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity) // Make label take full width
            }
            .buttonStyle(.borderedProminent) // Primary action style
            .controlSize(.large)
            .tint(.indigo)

            // Settings Button
            Button {
                // Settings Action (e.g., navigate to Settings view)
            } label: {
                Label("Settings", systemImage: "gearshape.fill")
                     .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered) // Secondary action style
             .controlSize(.large)
             .tint(.secondary) // Muted tint for settings
        }
        .padding(.horizontal)
        .padding(.top, 10) // Add space above buttons
    }


    // MARK: - Loading and Error Views (Reused or Custom)
    private var loadingView: some View {
        VStack(spacing: 10) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading Your Passport...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 150)
    }

    private func errorView(message: String) -> some View {
         VStack(spacing: 15) {
             Image(systemName: "exclamationmark.triangle.fill")
                 .font(.system(size: 40))
                 .foregroundColor(.orange)
             Text("Could not load profile.")
                 .font(.title3).bold()
             Text(message)
                 .font(.subheadline)
                 .foregroundColor(.secondary)
                 .multilineTextAlignment(.center)
                 .padding(.horizontal, 30)
             Button("Try Again") {
                  userProfile.loadUserProfile()
             }
             .buttonStyle(.bordered)
             .tint(.orange)
         }
         .frame(maxWidth: .infinity)
         .padding(.vertical, 120)
    }
}

// MARK: - Passport View Components

struct HimachalPassportView: View {
    let stamps: [PassportStamp]
    let columns = [GridItem(.adaptive(minimum: 85), spacing: 15)] // Adaptive columns for stamps

    var body: some View {
         VStack(alignment: .leading) {
            // Title inside the passport background (optional)
            // Text("PASSPORT")
            //     .font(.system(size: 14, weight: .medium, design: .monospaced))
            //     .foregroundColor(.blue.opacity(0.6))
            //     .padding(.top, 10)
            //     .padding(.leading, 15)

            if stamps.isEmpty {
                 Spacer() // Push text to center
                 Text("Visit places to collect stamps!")
                     .font(.headline)
                     .foregroundColor(.secondary.opacity(0.7))
                     .frame(maxWidth: .infinity, alignment: .center)
                 Spacer()
            } else {
                ScrollView { // Make stamps scrollable if they exceed height
                    LazyVGrid(columns: columns, spacing: 20) { // Increased spacing
                        ForEach(stamps) { stamp in
                            PassportStampView(stamp: stamp)
                        }
                    }
                    .padding(10) // Padding inside the grid
                }
            }
        }
        // Removed background from here, applied in PassportView's passportSection
    }
}

struct PassportStampView: View {
    let stamp: PassportStamp
    @State private var isStamped = false // Animation state

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                // Stamp Shape (more interesting than circle)
                StampShape()
                    .fill(Color.red.opacity(isStamped ? 0.15 : 0)) // Faint background on stamp
                    .frame(width: 75, height: 75)

                StampShape()
                    .stroke(Color.red.opacity(isStamped ? 0.8 : 0), lineWidth: 2) // Red border
                     .rotationEffect(.degrees(isStamped ? -15 : 15)) // Rotation animation
                    .frame(width: 75, height: 75)


                Text(stamp.icon) // Use the icon from data
                    .font(.system(size: 35))
                     .foregroundColor(.red.opacity(isStamped ? 0.9 : 0.2)) // Fade in icon

                 // Date overlay (optional, can make it cluttered)
                 // Text(stamp.date.formatted(.dateTime.year()))
                 //    .font(.system(size: 8, weight: .bold))
                 //    .foregroundColor(.red.opacity(0.6))
                 //    .offset(y: 25)
            }
            .scaleEffect(isStamped ? 1.0 : 0.8) // Scale effect

            Text(stamp.location)
                .font(.caption).bold() // Bold location name
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 35, alignment: .top) // Fixed height for alignment
        }
         .frame(width: 85) // Overall width constraint
         .onAppear {
              // Trigger animation shortly after appearing
             withAnimation(.interpolatingSpring(mass: 0.5, stiffness: 100, damping: 10).delay(Double.random(in: 0.1...0.5))) {
                 isStamped = true
             }
         }
    }
}

// Custom Shape for the Stamp Border
struct StampShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waves = 12 // Number of waves around the circle
        let amplitude = rect.width * 0.04 // Wave amplitude

        for i in 0...waves {
            let angle = Angle.degrees(Double(i) * (360.0 / Double(waves)))
            let radius = (rect.width / 2) + (i % 2 == 0 ? -amplitude : amplitude) // Alternate amplitude

            let x = rect.midX + cos(angle.radians) * radius
            let y = rect.midY + sin(angle.radians) * radius

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                 // Add curve for smoother waves (optional)
                // let prevAngle = Angle.degrees(Double(i-1) * (360.0 / Double(waves)))
                // let controlRadius = (rect.width / 2)
                // let cx = rect.midX + cos(prevAngle.radians + angle.radians/2) * controlRadius
                // let cy = rect.midY + sin(prevAngle.radians + angle.radians/2) * controlRadius
                // path.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: cx, y: cy))

                 // Simpler line version
                 path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}


struct JourneyCard: View {
    let journey: Journey

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                     Text(journey.title)
                        .font(.headline).bold() // Bold title
                     Text("\(journey.startDate.formatted(.dateTime.month().day())) - \(journey.endDate.formatted(.dateTime.month().day().year()))") // Concise date format
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                 // Status Badge
                Text(journey.status.rawValue.uppercased()) // Uppercase status
                    .font(.caption).bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(journey.status.color.opacity(0.15)) // Use status color
                    .foregroundColor(journey.status.color)
                    .clipShape(Capsule())
            }

            // Waypoints using icons/text (limit display)
            HStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill") // Start icon
                 ForEach(journey.waypoints.prefix(3), id: \.self) { waypoint in
                    Text(waypoint)
                         .font(.caption)
                         .lineLimit(1)
                    if waypoint != journey.waypoints.prefix(3).last {
                         Image(systemName: "arrow.right") // Arrow between waypoints
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                if journey.waypoints.count > 3 {
                    Text("...") // Indicate more waypoints
                         .font(.caption)
                }
                Image(systemName: "flag.circle.fill") // End icon
            }
            .foregroundColor(.secondary) // Color for the waypoint line
        }
        .padding() // Padding inside the card
        .background(Color(UIColor.secondarySystemGroupedBackground)) // Card background
        .cornerRadius(15)
         .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2) // Softer shadow
    }
}

struct ContributionCard: View {
    let contribution: Contribution

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(contribution.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 150) // Match Discover card size
                .clipShape(RoundedRectangle(cornerRadius: 15))

             VStack(alignment: .leading, spacing: 4) { // Reduce spacing
                Text(contribution.location)
                    .font(.headline)
                    .lineLimit(1)

                 // Show only date, maybe likes/comments if available
                Text("Added: \(contribution.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                 // Description is optional here or shown on tap
                 // Text(contribution.description)
                 //    .font(.caption)
                 //    .foregroundColor(.secondary)
                 //    .lineLimit(2)
            }
            .padding(.horizontal, 5) // Padding for text
        }
         .frame(width: 200) // Card width
         .padding(10)
         .background(Color(UIColor.secondarySystemGroupedBackground))
         .cornerRadius(18)
         .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - UserProfileViewModel Extension (for refreshable)

extension UserProfileViewModel {
     @MainActor
     func asyncLoadUserProfile() async {
         // Simulate network delay
         try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
         loadUserProfile()
     }
}

// MARK: - Profile Details Sheet
struct ProfileDetailsSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var tempUsername: String
    @State private var tempContact: String
    @State private var tempGender: String
    @State private var tempNationality: String
    @State private var tempDomicile: String

    init() {
        _tempUsername = State(initialValue: ProfileDetails.username)
        _tempContact = State(initialValue: ProfileDetails.contact)
        _tempGender = State(initialValue: ProfileDetails.gender)
        _tempNationality = State(initialValue: ProfileDetails.nationality)
        _tempDomicile = State(initialValue: ProfileDetails.domicile)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Username", text: $tempUsername)
                    TextField("Contact", text: $tempContact)
                    TextField("Gender", text: $tempGender)
                    TextField("Nationality", text: $tempNationality)
                    TextField("Domicile", text: $tempDomicile)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    saveChanges()
                    dismiss()
                }
            )
        }
    }

    private func saveChanges() {
        ProfileDetails.username = tempUsername
        ProfileDetails.contact = tempContact
        ProfileDetails.gender = tempGender
        ProfileDetails.nationality = tempNationality
        ProfileDetails.domicile = tempDomicile
    }
}
