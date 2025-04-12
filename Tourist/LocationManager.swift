//
//  LocationManager.swift
//  Tourist
//
//  Created by aryaman jaiswal on 12/04/25.
//
import CoreLocation
import Combine
import SwiftUI // Import SwiftUI for @Published

// MARK: - Location Manager Class

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    // The CLLocationManager instance
    private let manager = CLLocationManager()

    // Published property to hold the latest location coordinate
    // Default to a known location like Shimla until a real location is available
    @Published var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 31.1048, longitude: 77.1734)

    // Published property to track authorization status
    @Published var authorizationStatus: CLAuthorizationStatus

    // Initialize the location manager
    override init() {
        // Get the initial authorization status
        authorizationStatus = manager.authorizationStatus
        super.init() // Call NSObject's init
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest // Set desired accuracy
        // Note: Requesting permission and starting updates often happen after init or on user action
        // requestPermission() // You might call this later, e.g., in onAppear
        // startUpdating()     // Or this
    }

    // Function to request location permission from the user
    func requestPermission() {
        // Only request if status is undetermined
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        // Or handle cases where permission was denied previously
    }

    // Function to start location updates
    func startUpdating() {
        // Check if location services are enabled device-wide and app has permission
        if CLLocationManager.locationServicesEnabled() && (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) {
            manager.startUpdatingLocation()
            print("Location Manager: Started updating location.")
        } else {
            print("Location Manager: Cannot start updating - Services disabled or not authorized (\(authorizationStatus.rawValue)).")
            // Optionally, re-request permission or guide user to settings
            if authorizationStatus == .denied || authorizationStatus == .restricted {
                 // Handle denied state - maybe show an alert guiding to settings
                 print("Location Manager: Permission denied or restricted.")
            } else if authorizationStatus == .notDetermined {
                requestPermission() // Request if not yet determined
            }
        }
    }

    // Function to stop location updates
    func stopUpdating() {
        manager.stopUpdatingLocation()
        print("Location Manager: Stopped updating location.")
    }


    // MARK: - CLLocationManagerDelegate Methods

    // Called when the authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("Location Manager: Authorization status changed to: \(authorizationStatus.rawValue)")

        // Automatically start updating if permission granted
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startUpdating()
        } else {
            // Stop updating if permission revoked or denied
            stopUpdating()
            // Handle specific denied/restricted cases if needed
        }
    }

    // Called when new location data is available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Update the published property with the last known location's coordinate
        if let location = locations.last?.coordinate {
            currentLocation = location
            // print("Location Manager: Updated location to \(location.latitude), \(location.longitude)")
            // Optional: Stop updating after first good location if needed for battery saving
            // stopUpdating()
        }
    }

    // Called when location manager fails to retrieve location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager: Failed to get location - Error: \(error.localizedDescription)")
        // Optionally, handle specific errors (e.g., network unavailable, denied access)
        // Maybe set a default location or show an error message to the user
    }
}
