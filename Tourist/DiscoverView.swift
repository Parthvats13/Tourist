import SwiftUI

// MARK: - Discover Tab

struct DiscoverView: View {
    @State private var searchText = ""
    @EnvironmentObject private var discoverViewModel: DiscoverViewModel
    
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
                    
                    if discoverViewModel.isLoading {
                        VStack {
                            ProgressView()
                            Text("Loading discover content...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else if let errorMessage = discoverViewModel.errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                                .padding()
                            
                            Text("Error loading content")
                                .font(.headline)
                            
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button("Try Again") {
                                discoverViewModel.loadDiscoverData()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
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
                                    ForEach(discoverViewModel.hiddenGems) { gem in
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
                                    ForEach(discoverViewModel.localGuides) { guide in
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
                            
                            ForEach(discoverViewModel.festivals.filter { $0.isSoon }.prefix(3)) { festival in
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
                                    ForEach(discoverViewModel.communityStories) { story in
                                        CommunityStoryCard(story: story)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Discover Himachal")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                discoverViewModel.loadDiscoverData()
            }
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
            @EnvironmentObject private var discoverViewModel: DiscoverViewModel
            
            let allLanguages = ["English", "Hindi", "French", "German", "Spanish", "Japanese"]
            let allSpecialties = ["Adventure", "Photography", "Culture", "Wildlife", "Trekking", "Yoga"]
            
            var filteredGuides: [LocalGuide] {
                return discoverViewModel.localGuides.filter { guide in
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
