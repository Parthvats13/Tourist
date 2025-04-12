import SwiftUI
import CoreLocation

// MARK: - Content View with Tab Navigation

struct ContentView: View {
    // Use constants for tab tags for better readability and maintenance
    enum Tab {
        case plan, map, discover, passport
    }
    @State private var selectedTab: Tab = .plan // Use enum for selection
        @StateObject private var tripPlanner = TripPlannerViewModel()
        @StateObject private var userProfile = UserProfileViewModel()
        @StateObject private var discoverViewModel = DiscoverViewModel()
        
        // Remove this line as it's causing the conflict:
        // @StateObject private var locationManager = LocationManager()
        
        // Instead, use @EnvironmentObject to receive the one created in the App
        @EnvironmentObject private var locationManager: LocationManager
    var body: some View {
        TabView(selection: $selectedTab) {
            // Plan Tab
            PlanView()
                .tabItem {
                    Label("Plan", systemImage: "map.fill") // Use filled icons for active state hint
                }
                .tag(Tab.plan) // Use enum tag

            // Map Tab
            MapView()
                .tabItem {
                    Label("Map", systemImage: "globe.americas.fill") // More specific globe
                }
                .tag(Tab.map)

            // Discover Tab
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "sparkles") // More engaging icon
                }
                .tag(Tab.discover)

            // Passport Tab
            PassportView()
                .tabItem {
                    Label("Passport", systemImage: "person.crop.rectangle.stack.fill") // More relevant icon
                }
                .tag(Tab.passport)
        }
        // Apply a consistent accent color across the app
        .accentColor(.indigo) // Or choose another primary color
        .environmentObject(tripPlanner)
        .environmentObject(userProfile)
        .environmentObject(discoverViewModel)
        .environmentObject(locationManager)
        .onAppear {
            // Load initial data when app starts
            userProfile.loadUserProfile()
            discoverViewModel.loadDiscoverData()
            // Request location permissions early if needed
            locationManager.requestPermission()
        }
    }
}

// MARK: - Preview Provider

#Preview {
    ContentView()
        // Add mock data providers for previews if needed
        // .environmentObject(TripPlannerViewModel.mock())
        // .environmentObject(UserProfileViewModel.mock())
        // .environmentObject(DiscoverViewModel.mock())
        // .environmentObject(LocationManager())
}
