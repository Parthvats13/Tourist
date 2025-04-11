import SwiftUI
import CoreLocation

// MARK: - Content View with Tab Navigation

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var tripPlanner = TripPlannerViewModel()
    @StateObject private var userProfile = UserProfileViewModel()
    @StateObject private var discoverViewModel = DiscoverViewModel()
    @StateObject private var locationManager = LocationManager()
    
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
        .environmentObject(tripPlanner)
        .environmentObject(userProfile)
        .environmentObject(discoverViewModel)
        .environmentObject(locationManager)
        .onAppear {
            // Load initial data when app starts
            userProfile.loadUserProfile()
            discoverViewModel.loadDiscoverData()
        }
    }
}

// MARK: - Preview Provider

#Preview {
    ContentView()
}
