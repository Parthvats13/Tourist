import SwiftUI
import CoreLocation // Keep import

// MARK: - Map Tab View

struct MapView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var tripPlanner: TripPlannerViewModel // Access itinerary if needed for route display

    // Use an enum for Map Layers for clarity
    enum MapLayer: String, CaseIterable, Identifiable {
        case weather = "Weather"
        case roadConditions = "Roads"
        case emergency = "Emergency"
        case altitude = "Altitude"

        var id: String { self.rawValue }

        var systemImage: String {
            switch self {
            case .weather: "cloud.sun.fill"
            case .roadConditions: "road.lanes"
            case .emergency: "cross.case.fill"
            case .altitude: "mountain.2.fill"
            }
        }

        var color: Color {
            switch self {
            case .weather: .blue
            case .roadConditions: .orange
            case .emergency: .red
            case .altitude: .green
            }
        }
    }

    // State for MapKit integration (replace placeholder)
    // @State private var region = MKCoordinateRegion(...)
    @State private var mapType: MapType = .standard // Keep your enum
    @State private var activeLayers: Set<MapLayer> = [.weather] // Default active layers
    @State private var showingLogSheet = false

    var body: some View {
        // Use NavigationStack if map needs a title or toolbar items specific to it
        NavigationStack {
            ZStack {
                // MARK: - Map Placeholder (Replace with MapKit View)
                MapPlaceholderView(
                    currentLocation: locationManager.currentLocation,
                    mapType: mapType
                )
                .ignoresSafeArea(edges: .top) // Allow map to go under navigation bar slightly

                // MARK: - Map Controls Overlay
                VStack {
                    Spacer() // Pushes controls to the bottom

                    HStack(alignment: .bottom) {
                        // Log Experience Button (Bottom Left)
                        Button {
                            showingLogSheet = true
                        } label: {
                            Label("Log Experience", systemImage: "plus.circle.fill")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent) // Prominent style for primary action
                        .tint(.blue) // Consistent color
                        .controlSize(.regular)
                        .shadow(radius: 3) // Add subtle shadow
                        .padding(.leading)

                        Spacer() // Pushes layer controls to the right

                        // Layer & Map Type Controls (Bottom Right)
                        HStack(spacing: 10) {
                            // Map Type Toggle Menu
                            Menu {
                                Button { mapType = .standard } label: {
                                    Label("Standard", systemImage: "map")
                                }
                                Button { mapType = .satellite } label: {
                                    Label("Satellite", systemImage: "globe.asia.australia") // Different globe icon
                                }
                            } label: {
                                Image(systemName: mapType == .standard ? "map" : "globe.asia.australia")
                                    .imageScale(.large)
                                    .frame(width: 44, height: 44) // Consistent size
                                    .background(.thickMaterial, in: Circle()) // Material background
                                    .shadow(radius: 3)
                            }

                            // Layers Menu
                            Menu {
                                ForEach(MapLayer.allCases) { layer in
                                    Toggle(isOn: binding(for: layer)) {
                                        Label(layer.rawValue, systemImage: layer.systemImage)
                                    }
                                }
                            } label: {
                                Image(systemName: "list.bullet.below.rectangle")
                                    .imageScale(.large)
                                    .frame(width: 44, height: 44)
                                    .background(.thickMaterial, in: Circle())
                                    .shadow(radius: 3)
                            }
                        }
                        .padding(.trailing)
                    }
                    .padding(.bottom, 10) // Padding from bottom edge
                }
            }
            .navigationTitle("Journey Map")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingLogSheet) {
                // Present LogExperienceView in a sheet
                LogExperienceView()
            }
            // Optional: Add toolbar items if needed (e.g., center on user location)
            // .toolbar { ... }
        }
    }

    // Helper function to create a binding for the Set
    private func binding(for layer: MapLayer) -> Binding<Bool> {
        Binding<Bool>(
            get: { activeLayers.contains(layer) },
            set: { isActive in
                if isActive {
                    activeLayers.insert(layer)
                } else {
                    activeLayers.remove(layer)
                }
            }
        )
    }
}

// MARK: - Map Placeholder (Replace with MapKit)

struct MapPlaceholderView: View {
    let currentLocation: CLLocationCoordinate2D
    let mapType: MapType // Use the enum

    var body: some View {
        ZStack {
            // Basic background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.green.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack {
                Image(systemName: mapType == .standard ? "map.fill" : "map")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 10)

                Text("Interactive Map (\(mapType == .standard ? "Standard" : "Satellite"))")
                    .font(.title2).bold()
                    .foregroundColor(.white)
                    .shadow(radius: 2)

                 if CLLocationCoordinate2DIsValid(currentLocation) {
                    Text("Current Location: \(String(format: "%.4f, %.4f", currentLocation.latitude, currentLocation.longitude))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 4)
                } else {
                     Text("Location not available")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 4)
                }

                 // Add hint about overlays
                 Text("Weather & Road Layers Active (Example)")
                     .font(.footnote)
                     .foregroundColor(.white.opacity(0.8))
                     .padding(.top, 10)
            }
            .padding()
        }
    }
}


// MARK: - Log Experience Sheet View

struct LogExperienceView: View {
    @Environment(\.dismiss) var dismiss // Use new dismiss environment variable
    @State private var experienceText = ""
    @State private var selectedImage: Image? // Use SwiftUI Image for display
    @State private var showImagePicker = false
    // @State private var inputImage: UIImage? // For handling UIImage from picker

    var body: some View {
        NavigationView { // Embed in NavigationView for Title and Buttons
            Form { // Use Form for better layout and standard controls
                Section("Photo (Optional)") {
                    if let image = selectedImage {
                        image
                            .resizable()
                            .scaledToFit() // Fit maintains aspect ratio
                            .frame(maxHeight: 300) // Limit display height
                            .cornerRadius(12)
                            .onTapGesture { showImagePicker = true } // Allow changing image
                    } else {
                        Button {
                            showImagePicker = true
                        } label: {
                            Label("Add Photo", systemImage: "camera.fill")
                                .frame(maxWidth: .infinity, alignment: .center) // Center label
                        }
                        .frame(height: 150) // Placeholder height
                    }
                }

                Section("Your Experience") {
                     // Use placeholder text within TextEditor
                    TextEditor(text: $experienceText)
                        .frame(minHeight: 100, maxHeight: 200)
                        .overlay( // Add placeholder text if editor is empty
                            HStack {
                                if experienceText.isEmpty {
                                    Text("Describe the place, view, or feeling...")
                                        .foregroundColor(Color(UIColor.placeholderText))
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                    Spacer()
                                }
                            }
                         )
                }

                Section { // Separate section for the Save button
                    Button("Save Experience") {
                        // TODO: Add save logic here
                        // let location = // Get current location or location where pin was dropped
                        // let imageToSave = inputImage // Get the UIImage if needed for saving
                        // saveExperience(text: experienceText, image: imageToSave, location: location)
                        dismiss() // Dismiss the sheet
                    }
                    .disabled(experienceText.isEmpty) // Disable if no text entered
                    .frame(maxWidth: .infinity, alignment: .center) // Center button text
                }
            }
            .navigationTitle("Log Experience")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            // TODO: Implement Image Picker
            // .sheet(isPresented: $showImagePicker) {
            //    ImagePicker(selectedImage: $inputImage) // Your image picker implementation
            // }
            // .onChange(of: inputImage) { _ in loadImage() } // Update SwiftUI Image when UIImage changes
        }
    }

    // func loadImage() {
    //    guard let inputImage = inputImage else { return }
    //    selectedImage = Image(uiImage: inputImage)
    // }
}
