import SwiftUI

struct ContentView: View {
    enum Tab {
        case plan, map, discover, passport
    }

    @State private var selectedTab: Tab = .plan
    @State private var previousTab: Tab = .plan
    @StateObject private var tripPlanner = TripPlannerViewModel()
    @StateObject private var userProfile = UserProfileViewModel()
    @StateObject private var discoverViewModel = DiscoverViewModel()
    @StateObject private var locationManager = LocationManager()
    
    // Animation properties
    @Namespace private var animation
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background that changes based on selected tab
            tabBackground
                .animation(.interpolatingSpring(stiffness: 50, damping: 8), value: selectedTab)
            
            // Tab content with transitions
            TabView(selection: $selectedTab) {
                PlanView()
                    .matchedGeometryEffect(id: Tab.plan, in: animation, isSource: selectedTab == Tab.plan)
                    .tabItem {
                        Label("Plan", systemImage: selectedTab == .plan ? "map.fill" : "map")
                    }
                    .tag(Tab.plan)
                
                MapView()
                    .matchedGeometryEffect(id: Tab.map, in: animation, isSource: selectedTab == Tab.map)
                    .tabItem {
                        Label("Map", systemImage: selectedTab == .map ? "globe.americas.fill" : "globe.americas")
                    }
                    .tag(Tab.map)
                
                DiscoverView()
                    .matchedGeometryEffect(id: Tab.discover, in: animation, isSource: selectedTab == Tab.discover)
                    .tabItem {
                        Label("Discover", systemImage: selectedTab == .discover ? "sparkles" : "sparkle")
                    }
                    .tag(Tab.discover)
                
                PassportView()
                    .matchedGeometryEffect(id: Tab.passport, in: animation, isSource: selectedTab == Tab.passport)
                    .tabItem {
                        Label("Passport", systemImage: selectedTab == .passport ? "person.crop.rectangle.stack.fill" : "person.crop.rectangle.stack")
                    }
                    .tag(Tab.passport)
            }
            .onChange(of: selectedTab) { newTab in
                previousTab = newTab
                
                // Add haptic feedback on tab change
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.impactOccurred()
            }
            .accentColor(.indigo)
            .environmentObject(tripPlanner)
            .environmentObject(userProfile)
            .environmentObject(discoverViewModel)
            .environmentObject(locationManager)
            .onAppear {
                userProfile.loadUserProfile()
                discoverViewModel.loadDiscoverData()
                locationManager.requestPermission()
                
                // Subtle animation when app first appears
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isAnimating = true
                }
            }
        }
    }
    
    // Dynamic background based on the selected tab
    private var tabBackground: some View {
        Group {
            switch selectedTab {
            case .plan:
                Color.indigo.opacity(0.05)
            case .map:
                Color.green.opacity(0.05)
            case .discover:
                Color.orange.opacity(0.05)
            case .passport:
                Color.purple.opacity(0.05)
            }
        }
        .ignoresSafeArea()
    }
}
#Preview {
    ContentView()
        // Add mock data providers for previews if needed
        // .environmentObject(TripPlannerViewModel.mock())
        // .environmentObject(UserProfileViewModel.mock())
        // .environmentObject(DiscoverViewModel.mock())
        // .environmentObject(LocationManager())
}
