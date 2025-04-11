//
//  TouristApp.swift
//  Tourist
//
//  Created by Parth Vats on 11/04/25.
//

import SwiftUI

@main
struct HimYatraApp: App {
    @StateObject private var userProfile = UserProfileViewModel()
    @StateObject private var tripPlanner = TripPlannerViewModel()
    @StateObject private var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userProfile)
                .environmentObject(tripPlanner)
                .environmentObject(locationManager)
        }
    }
}
