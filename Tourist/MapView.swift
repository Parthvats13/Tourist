import SwiftUI
import CoreLocation

// MARK: - Map Tab

struct MapView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var tripPlanner: TripPlannerViewModel
    @State private var mapType: MapType = .standard
    @State private var showWeatherOverlay = true
    @State private var showRoadConditions = true
    @State private var showEmergencyServices = false
    @State private var showAltitudeInfo = false
    @State private var showingLogSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map placeholder (this would be MapKit in a real app)
                Color.gray.opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        VStack {
                            Image(systemName: "map")
                                .font(.system(size: 50))
                            Text("Interactive Map View")
                                .font(.title)
                                .padding(.top)
                            Text("Current location: \(formatCoordinate(locationManager.currentLocation))")
                                .font(.caption)
                                .padding(.top, 4)
                        }
                    )
                
                // Overlay controls
                VStack {
                    HStack {
                        Spacer()
                        
                        VStack {
                            Button(action: {
                                mapType = mapType == .standard ? .satellite : .standard
                            }) {
                                Image(systemName: mapType == .standard ? "globe" : "map")
                                    .padding()
                                    .background(Circle().fill(Color.white))
                                    .shadow(radius: 3)
                            }
                            
                            MapFilterButton(
                                isActive: $showWeatherOverlay,
                                icon: "cloud.sun.fill",
                                color: .blue
                            )
                            
                            MapFilterButton(
                                isActive: $showRoadConditions,
                                icon: "road.lanes",
                                color: .orange
                            )
                            
                            MapFilterButton(
                                isActive: $showEmergencyServices,
                                icon: "cross.case.fill",
                                color: .red
                            )
                            
                            MapFilterButton(
                                isActive: $showAltitudeInfo,
                                icon: "mountain.2.fill",
                                color: .green
                            )
                        }
                        .padding(.trailing)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingLogSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Log Experience")
                        }
                        .padding()
                        .background(Capsule().fill(Color.blue))
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                    }
                    .padding(.bottom)
                }
                .padding()
            }
            .navigationTitle("Journey Map")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingLogSheet) {
                LogExperienceView()
            }
        }
    }
    
    private func formatCoordinate(_ coordinate: CLLocationCoordinate2D) -> String {
        return "\(String(format: "%.4f", coordinate.latitude)), \(String(format: "%.4f", coordinate.longitude))"
    }
}

struct MapFilterButton: View {
    @Binding var isActive: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            isActive.toggle()
        }) {
            Image(systemName: icon)
                .foregroundColor(isActive ? color : .gray)
                .padding()
                .background(Circle().fill(Color.white))
                .shadow(radius: 3)
        }
    }
}

struct LogExperienceView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var experienceText = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .clipped()
                } else {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        VStack {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                            Text("Add Photo")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                
                TextField("What's special about this place?", text: $experienceText)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Button(action: {
                    // Save experience functionality
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save Experience")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Log Experience")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showImagePicker) {
                // This would be the actual image picker in a real app
                Text("Image Picker Placeholder")
                    .padding()
            }
        }
    }
}
