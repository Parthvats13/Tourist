import SwiftUI

// MARK: - Passport Tab

struct PassportView: View {
    @EnvironmentObject private var userProfile: UserProfileViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                if userProfile.isLoading {
                    VStack {
                        ProgressView()
                        Text("Loading your passport...")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 50)
                } else if let errorMessage = userProfile.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                            .padding()
                        
                        Text("Error loading profile")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Try Again") {
                            userProfile.loadUserProfile()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
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
                            
                            if userProfile.journeys.isEmpty {
                                Text("You haven't started any journeys yet.")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(userProfile.journeys) { journey in
                                    JourneyCard(journey: journey)
                                        .padding(.horizontal)
                                }
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
                }
            }
            .navigationTitle("My HimYatra")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                userProfile.loadUserProfile()
            }
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
