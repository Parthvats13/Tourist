import SwiftUI

// MARK: - Discover Tab View

struct DiscoverView: View {
    @EnvironmentObject private var discoverViewModel: DiscoverViewModel
    @State private var searchText = "" // For searchable modifier

    var body: some View {
        NavigationStack {
            ScrollView {
                // Use LazyVStack for performance with many sections/items
                LazyVStack(alignment: .leading, spacing: 30, pinnedViews: [.sectionHeaders]) {

                    // Conditional Content: Loading, Error, Success
                    if discoverViewModel.isLoading {
                        loadingView
                    } else if let errorMessage = discoverViewModel.errorMessage {
                        errorView(message: errorMessage)
                    } else {
                        // MARK: - Categories Section
                        Section {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    // Create dummy categories or load from ViewModel if available
                                    CategoryCard(title: "Adventure", image: "discover_adventure", icon: "figure.hiking")
                                    CategoryCard(title: "Religious", image: "discover_religious", icon: "building.columns.fill")
                                    CategoryCard(title: "Nature", image: "discover_nature", icon: "leaf.fill")
                                    CategoryCard(title: "Cultural", image: "discover_cultural", icon: "theatermasks.fill")
                                    CategoryCard(title: "Foodie", image: "discover_food", icon: "fork.knife")
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 5) // Space below scroll view
                            }
                        } header: {
                            DiscoverSectionHeader(title: "Explore Categories")
                        }

                        // MARK: - Hidden Gems Section
                        Section {
                            if discoverViewModel.hiddenGems.isEmpty {
                                emptySectionView(message: "No hidden gems found right now.")
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(discoverViewModel.hiddenGems) { gem in
                                             NavigationLink {
                                                 // Destination: Gem Detail View (Create this view)
                                                 Text("Detail for \(gem.name)")
                                             } label: {
                                                HiddenGemCard(gem: gem)
                                             }
                                             .buttonStyle(.plain) // Use plain style for nav link cards
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 5)
                                }
                            }
                        } header: {
                            DiscoverSectionHeader(title: "Gems Nearby")
                        }

                        // MARK: - Local Guides Section
                        Section {
                            if discoverViewModel.localGuides.isEmpty {
                                emptySectionView(message: "No local guides available currently.")
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(discoverViewModel.localGuides.prefix(5)) { guide in // Show limited guides
                                            NavigationLink {
                                                GuideDetailView(guide: guide)
                                            } label: {
                                                LocalGuideCard(guide: guide)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 5)
                                }
                            }
                        } header: {
                             DiscoverSectionHeader(title: "Local Guides") {
                                 // Action: Navigate to All Guides View
                                 NavigationLink("See All", destination: AllGuidesView())
                                      .font(.subheadline) // Match font size
                             }
                        }

                        // MARK: - Upcoming Festivals Section
                        Section {
                            let upcomingFestivals = discoverViewModel.festivals.filter { $0.isSoon }.prefix(3)
                            if upcomingFestivals.isEmpty {
                                 emptySectionView(message: "No upcoming festivals to show.")
                             } else {
                                VStack(spacing: 12) { // Vertical list for festivals
                                    ForEach(upcomingFestivals) { festival in
                                         NavigationLink {
                                             // Destination: Festival Detail View (Create this view)
                                             Text("Detail for \(festival.name)")
                                         } label: {
                                            FestivalCard(festival: festival)
                                         }
                                         .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } header: {
                            DiscoverSectionHeader(title: "Festivals Happening Soon")
                        }


                        // MARK: - Community Stories Section
                        Section {
                             if discoverViewModel.communityStories.isEmpty {
                                emptySectionView(message: "No community stories shared yet.")
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(discoverViewModel.communityStories) { story in
                                             NavigationLink {
                                                 // Destination: Story Detail View (Create this view)
                                                 Text("Detail for \(story.title)")
                                             } label: {
                                                 CommunityStoryCard(story: story)
                                             }
                                             .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 5)
                                }
                            }
                        } header: {
                             DiscoverSectionHeader(title: "Community Stories")
                        }
                    }
                }
                .padding(.vertical) // Overall vertical padding for the VStack content
            }
             // Native Search Bar
            .searchable(text: $searchText, prompt: "Search Himachal...")
             // Add background if needed
            // .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Discover") // Keep large title default for Discover
            .refreshable { // Pull to refresh
                await discoverViewModel.asyncLoadDiscoverData() // Assume an async version exists
            }
             // Handle search submission (optional)
            // .onSubmit(of: .search) {
            //     performSearch(query: searchText)
            // }
        }
        // Apply accent color to the NavigationStack if needed
        // .accentColor(.indigo)
    }

     // MARK: - Loading and Error Views
    private var loadingView: some View {
         VStack(spacing: 10) {
             ProgressView()
                 .scaleEffect(1.5) // Make spinner larger
             Text("Loading Discover...")
                 .font(.headline)
                 .foregroundColor(.secondary)
         }
         .frame(maxWidth: .infinity)
         .padding(.vertical, 100)
    }

     private func errorView(message: String) -> some View {
          VStack(spacing: 15) {
              Image(systemName: "exclamationmark.triangle.fill")
                  .font(.system(size: 40))
                  .foregroundColor(.orange)
              Text("Oops! Something went wrong.")
                  .font(.title3).bold()
              Text(message)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                  .multilineTextAlignment(.center)
                  .padding(.horizontal, 30)
              Button("Try Again") {
                   discoverViewModel.loadDiscoverData()
              }
              .buttonStyle(.bordered)
              .tint(.orange)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 80)
     }

    private func emptySectionView(message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal)
            .padding(.vertical, 20) // Add padding for empty state
    }
}

// MARK: - Discover Section Header

struct DiscoverSectionHeader<TrailingContent: View>: View {
    let title: String
    var trailingContent: (() -> TrailingContent)? = nil // Optional trailing view (like "See All")

     // Initializer for simple title
     init(title: String) where TrailingContent == EmptyView {
         self.title = title
         self.trailingContent = nil
     }

    // Initializer with trailing content closure
    init(title: String, @ViewBuilder trailingContent: @escaping () -> TrailingContent) {
         self.title = title
         self.trailingContent = trailingContent
     }


    var body: some View {
        HStack {
            Text(title)
                .font(.title2).bold()
                .foregroundColor(.primary) // Ensure readability

            Spacer()

            // Render trailing content if provided
            trailingContent?()
                .font(.subheadline) // Ensure consistent size for "See All" etc.

        }
        .padding(.horizontal)
        .padding(.top, 15) // Space above the header
        .padding(.bottom, 8) // Space below the header
        .background(.ultraThinMaterial) // Sticky header background
    }
}


// MARK: - Discover Card Styles

struct CategoryCard: View {
    let title: String
    let image: String // Asset name
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(image) // Use the specific image name
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 130, height: 100) // Adjust size
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay( // Gradient overlay for depth
                    LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.5)]),
                                   startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(12) // Apply after overlay

            Label(title, systemImage: icon)
                .font(.caption).bold() // Smaller font for category title
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .frame(width: 130) // Ensure VStack takes the width
    }
}

struct HiddenGemCard: View {
    let gem: HiddenGem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(gem.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 220, height: 160) // Larger image for gems
                .clipShape(RoundedRectangle(cornerRadius: 15))
                 .overlay( // Title overlay at the bottom
                    VStack {
                        Spacer()
                        Text(gem.name)
                            .font(.headline).bold()
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                    }
                 )
                 .cornerRadius(15) // Apply after overlay


            Text(gem.location)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)

            HStack {
                Label("\(gem.visitors) visits", systemImage: "person.3.fill") // More descriptive icon
                     .font(.caption)
                     .foregroundColor(.secondary)
                 Spacer()
                HStack(spacing: 2) {
                     Image(systemName: "star.fill")
                         .foregroundColor(.yellow)
                     Text(String(format: "%.1f", gem.rating))
                }
                .font(.caption).bold() // Make rating bold
                .foregroundColor(.orange) // Use orange for rating
            }
        }
        .frame(width: 220) // Width constraint for the card
        .padding(8) // Padding inside the background
        .background(Color(UIColor.secondarySystemGroupedBackground)) // Card background
        .cornerRadius(18) // Slightly larger radius for outer card
         .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct LocalGuideCard: View {
    let guide: LocalGuide

    var body: some View {
        VStack(spacing: 8) {
            Image(guide.profileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80) // Size of profile image
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 1)) // Subtle border
                .shadow(radius: 3)

            Text(guide.name)
                .font(.headline)
                .lineLimit(1)

            Text(guide.specialty.joined(separator: ", "))
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)

            // Star Rating
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                     Image(systemName: index < Int(round(guide.rating)) ? "star.fill" : "star")
                         .font(.caption) // Consistent size
                         .foregroundColor(.yellow)
                }
            }

            // Languages as pills
             ScrollView(.horizontal, showsIndicators: false) { // Prevent language overflow
                HStack(spacing: 4) {
                    ForEach(guide.languages.prefix(2), id: \.self) { lang in // Limit displayed languages
                        Text(lang)
                            .font(.caption2).bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.teal.opacity(0.2))) // Use a different color
                            .foregroundColor(.teal)
                    }
                }
            }
            .frame(height: 20) // Constrain height of language scroll

        }
        .frame(width: 150) // Fixed width for consistency
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
}

struct FestivalCard: View {
    let festival: Festival

    var body: some View {
        HStack(spacing: 15) {
            Image(festival.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70) // Slightly smaller image
                .cornerRadius(10)
                .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(festival.name)
                    .font(.headline)
                Text(festival.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                 // Date formatting
                Label(festival.date.formatted(.dateTime.month(.abbreviated).day()), systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }

            Spacer() // Pushes content left

            if festival.isSoon {
                Text("SOON")
                    .font(.caption).bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.orange.opacity(0.9))) // Brighter orange
                    .foregroundColor(.white)
            }
        }
        // Remove extra padding and background if used within a List row
        // .padding() // Keep padding if used outside a List
        // .background(Color(UIColor.secondarySystemGroupedBackground))
        // .cornerRadius(15)
        // .shadow(radius: 1)
    }
}

struct CommunityStoryCard: View {
    let story: CommunityStory

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(story.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 250, height: 160) // Story image size
                .clipShape(RoundedRectangle(cornerRadius: 15))

            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(story.excerpt)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2) // Limit excerpt lines
            }
             .padding(.horizontal, 5) // Padding for text below image

            // Author Info
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
             .padding(.horizontal, 5)
        }
        .frame(width: 250) // Overall card width
        .padding(10)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(18)
         .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}


// MARK: - All Guides View

struct AllGuidesView: View {
    @EnvironmentObject private var discoverViewModel: DiscoverViewModel
    @State private var searchText = ""
    @State private var selectedLanguages: Set<String> = []
    @State private var selectedSpecialties: Set<String> = []
    @State private var showFilters = false // State to control filter sheet

     // Use computed property for filtering
     var filteredGuides: [LocalGuide] {
         discoverViewModel.localGuides.filter { guide in
            let searchMatch = searchText.isEmpty || guide.name.localizedCaseInsensitiveContains(searchText)
             // Check if guide's languages contain ALL selected languages
            let languageMatch = selectedLanguages.isEmpty || selectedLanguages.isSubset(of: Set(guide.languages))
            // Check if guide's specialties contain ANY selected specialties
            let specialtyMatch = selectedSpecialties.isEmpty || !Set(guide.specialty).isDisjoint(with: selectedSpecialties)

             return searchMatch && languageMatch && specialtyMatch
         }
     }

    let columns = [GridItem(.adaptive(minimum: 160), spacing: 15)] // Adaptive grid columns

    var body: some View {
        ScrollView {
             if filteredGuides.isEmpty && !discoverViewModel.localGuides.isEmpty && (!searchText.isEmpty || !selectedLanguages.isEmpty || !selectedSpecialties.isEmpty) {
                  // Show no results message only when filters/search are active
                 Text("No guides match your current filters.")
                     .foregroundColor(.secondary)
                     .padding(.top, 50)
                     .frame(maxWidth: .infinity)
            } else if discoverViewModel.localGuides.isEmpty {
                 Text("No local guides found.")
                     .foregroundColor(.secondary)
                     .padding(.top, 50)
                     .frame(maxWidth: .infinity)
            } else {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(filteredGuides) { guide in
                         NavigationLink {
                            GuideDetailView(guide: guide)
                        } label: {
                            LocalGuideCard(guide: guide)
                        }
                        .buttonStyle(PlainButtonStyle()) // Ensure card taps work correctly
                    }
                }
                .padding() // Padding around the grid
            }
        }
        .navigationTitle("Local Guides")
        .navigationBarTitleDisplayMode(.large) // Use large title for this screen
        .searchable(text: $searchText, prompt: "Search by name") // Add search bar
        .toolbar { // Add filter button to toolbar
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showFilters = true
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                         .symbolVariant(selectedLanguages.isEmpty && selectedSpecialties.isEmpty ? .none : .fill) // Fill icon if filters active
                }
            }
        }
        .sheet(isPresented: $showFilters) { // Present filters in a sheet
            GuideFiltersView(
                selectedLanguages: $selectedLanguages,
                selectedSpecialties: $selectedSpecialties,
                allLanguages: discoverViewModel.allAvailableLanguages, // Get from VM
                allSpecialties: discoverViewModel.allAvailableSpecialties // Get from VM
            )
             .presentationDetents([.medium, .large]) // Allow resizing
        }
         // Optional: Add background
         // .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Guide Filters View (Sheet)

struct GuideFiltersView: View {
    @Binding var selectedLanguages: Set<String>
    @Binding var selectedSpecialties: Set<String>
    let allLanguages: [String]
    let allSpecialties: [String]
    @Environment(\.dismiss) var dismiss

    var body: some View {
         NavigationView { // Add NavigationView for title and done button
             Form {
                 Section("Filter by Language") {
                     FilterSelectionView(
                        allItems: allLanguages,
                        selectedItems: $selectedLanguages
                     )
                 }

                Section("Filter by Specialty") {
                     FilterSelectionView(
                        allItems: allSpecialties,
                        selectedItems: $selectedSpecialties
                     )
                }

                 // Reset Button
                Section {
                    Button("Clear All Filters", role: .destructive) {
                        selectedLanguages.removeAll()
                        selectedSpecialties.removeAll()
                    }
                     .disabled(selectedLanguages.isEmpty && selectedSpecialties.isEmpty) // Disable if no filters are set
                     .frame(maxWidth: .infinity, alignment: .center)
                }
            }
             .navigationTitle("Filter Guides")
             .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button("Done") {
                         dismiss()
                     }
                 }
             }
         }
    }
}


// Reusable Filter Selection View (for Languages/Specialties)
struct FilterSelectionView: View {
    let allItems: [String]
    @Binding var selectedItems: Set<String>

    // Use adaptive grid layout for filters
    let columns = [GridItem(.adaptive(minimum: 100))]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(allItems, id: \.self) { item in
                FilterChip(
                    title: item,
                    isSelected: selectedItems.contains(item),
                    action: {
                        if selectedItems.contains(item) {
                            selectedItems.remove(item)
                        } else {
                            selectedItems.insert(item)
                        }
                    }
                )
            }
        }
        .padding(.vertical, 5) // Padding within the form row
    }
}


struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline) // Slightly larger than InterestChip
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                 .frame(maxWidth: .infinity) // Allow chip to expand
                .foregroundColor(isSelected ? .white : .accentColor)
                .background(isSelected ? Color.accentColor : Color.accentColor.opacity(0.15))
                .clipShape(Capsule())
                 .lineLimit(1) // Prevent text wrapping
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Guide Detail View

struct GuideDetailView: View {
    let guide: LocalGuide

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) { // Use 0 spacing for manual control

                // Header Section with Image Overlap
                ZStack(alignment: .bottomLeading) { // Align profile image to bottom left
                    // Background Image (could be generic or guide-specific if available)
                    Image("guide_header_background") // Use a generic header image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 220)
                        .clipped()
                        .overlay(LinearGradient(gradient: Gradient(colors: [.black.opacity(0.6), .clear]), startPoint: .top, endPoint: .center)) // Top gradient

                    // Profile Image
                    Image(guide.profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4)) // White border
                        .shadow(radius: 5)
                        .offset(y: 60) // Offset downwards to overlap
                        .padding(.leading, 20) // Padding from the left edge
                }
                .padding(.bottom, 60) // Space below the header for the offset image


                // Guide Name, Rating, and Contact Button
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(guide.name)
                            .font(.largeTitle).bold()

                        // Rating stars and count
                        HStack(spacing: 5) {
                            HStack(spacing: 2) {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < Int(round(guide.rating)) ? "star.fill" : "star")
                                         .foregroundColor(.yellow)
                                }
                            }
                            Text("(\(guide.reviewCount) Reviews)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Button {
                        // Contact Action (e.g., open mail, phone, chat)
                    } label: {
                        Label("Contact", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                     .tint(.blue) // Contact button color
                }
                .padding(.horizontal)
                .padding(.top, 20) // Space above name section


                // Details Section Card
                VStack(alignment: .leading, spacing: 15) { // Increase spacing inside card
                     DetailRow(icon: "briefcase.fill", title: "Experience", value: "\(guide.yearsExperience) years")
                     Divider()
                     DetailRow(icon: "map.fill", title: "Regions Covered", value: guide.regions.joined(separator: ", "))
                     Divider()
                    DetailRow(icon: "flag.fill", title: "Specialties", value: guide.specialty.joined(separator: ", "))
                    Divider()
                    DetailRow(icon: "globe.americas.fill", title: "Languages Spoken", value: guide.languages.joined(separator: ", "))
                }
                .padding() // Padding inside the card
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .padding() // Padding around the card


                // About Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("About \(guide.name)")
                        .font(.title2).bold()
                    Text(guide.bio)
                        .font(.body)
                         .foregroundColor(.secondary) // Slightly muted text for bio
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .padding(.horizontal)


                // Reviews Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Reviews")
                        .font(.title2).bold()

                    if guide.reviews.isEmpty {
                         Text("No reviews yet.")
                            .foregroundColor(.secondary)
                             .padding(.vertical)
                     } else {
                        // Show limited reviews, add "See All" if many
                        ForEach(guide.reviews.prefix(3)) { review in
                            ReviewCard(review: review)
                        }
                         if guide.reviewCount > 3 {
                            // TODO: Add "See All Reviews" NavigationLink
                            Button("See All \(guide.reviewCount) Reviews") {
                                // Navigate to All Reviews View
                            }
                            .padding(.top, 5)
                            .frame(maxWidth: .infinity, alignment: .center)
                         }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .padding() // Final padding around reviews

            }
        }
        .navigationTitle("Guide Profile")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top) // Allow content to go under status bar if needed
         // Optional: Add background
         // .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top) { // Align top for multi-line values
            Image(systemName: icon)
                .font(.headline) // Match title font size
                .foregroundColor(.accentColor) // Use accent color
                .frame(width: 25, alignment: .center) // Fixed width for alignment

            Text(title)
                .font(.headline) // Bold title
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary) // Muted value text
                 .multilineTextAlignment(.trailing) // Align multi-line text right
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

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.userName)
                        .font(.headline)

                    // Rating and Date combined
                    HStack(spacing: 5) {
                        HStack(spacing: 1) { // Compact stars
                            ForEach(0..<5) { index in
                                Image(systemName: index < review.rating ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                        }
                         Text("·") // Separator
                         Text(review.date.formatted(date: .numeric, time: .omitted)) // Compact date
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer() // Pushes date to the right if needed
            }

            Text(review.comment)
                .font(.subheadline)
                 .foregroundColor(.primary.opacity(0.8)) // Slightly less prominent comment text
                .lineLimit(4) // Limit review length displayed initially
        }
        .padding() // Padding inside the card
        .background(Color(UIColor.tertiarySystemGroupedBackground)) // Card background
        .cornerRadius(12)
    }
}


// MARK: - ViewModel Extensions (for Discover data)

// Add these computed properties to DiscoverViewModel for cleaner access in Views
extension DiscoverViewModel {
    var allAvailableLanguages: [String] {
        // Extract unique languages from all guides
        Set(localGuides.flatMap { $0.languages }).sorted()
    }

    var allAvailableSpecialties: [String] {
        // Extract unique specialties from all guides
        Set(localGuides.flatMap { $0.specialty }).sorted()
    }

     // Example of an async loading function for refreshable
     @MainActor // Ensure updates happen on main thread
     func asyncLoadDiscoverData() async {
          // Simulate network delay
          try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
          loadDiscoverData()
     }
}
struct AnimatedCardContainer<Content: View>: View {
    let delay: Double
    let content: Content
    @State private var isShowing = false
    
    init(delay: Double = 0, @ViewBuilder content: () -> Content) {
        self.delay = delay
        self.content = content()
    }
    
    var body: some View {
        content
            .scaleEffect(isShowing ? 1 : 0.8)
            .opacity(isShowing ? 1 : 0)
            .offset(y: isShowing ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5).delay(delay), value: isShowing)
            .onAppear {
                isShowing = true
            }
            .onDisappear {
                isShowing = false
            }
    }
}
