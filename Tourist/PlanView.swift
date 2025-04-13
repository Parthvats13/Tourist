import SwiftUI
import CoreLocation

import Combine

struct Hotel: Identifiable, Codable {
    let id: String
    let name: String
    let location: String
    let description: String
    let address: String
    let price: Int
    let rating: Double
    let images: [String]
    let mainImage: String
    let amenities: [String]
    let roomTypes: [RoomType]
    let reviews: [Review]
    let contactPhone: String
    let contactEmail: String
    let coordinates: Coordinates

    struct RoomType: Identifiable, Codable {
        let id: String
        let name: String
        let price: Int
        let capacity: Int
        let description: String
        let image: String
    }

    struct Review: Identifiable, Codable {
        var id: String { author + date }
        let author: String
        let rating: Int
        let comment: String
        let date: String
    }

    struct Coordinates: Codable {
        let latitude: Double
        let longitude: Double
    }
}

class HotelViewModel: ObservableObject {
    @Published var hotels: [Hotel] = []
    @Published var isLoading = false
    @Published var error: String? = nil

    private let apiService = APIService()
    private var cancellables = Set<AnyCancellable>()

    func loadHotels(for location: String) {
        isLoading = true
        error = nil

        apiService.getRequest(endpoint: "hotels")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            }, receiveValue: { [weak self] (response: APIResponse<[Hotel]>) in
                // Filter hotels by location if specified
                if !location.isEmpty {
                    self?.hotels = response.data.filter { $0.location == location }
                } else {
                    self?.hotels = response.data
                }
            })
            .store(in: &cancellables)
    }
}

struct HotelListView: View {
    @StateObject private var viewModel = HotelViewModel()
    let location: String

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                LoadingView(message: "Finding the best hotels...")
            } else if let error = viewModel.error {
                ErrorView(message: error)
            } else if viewModel.hotels.isEmpty {
                EmptyStateView2(
                    message: "No hotels found for \(location)",
                    icon: "bed.double"
                )
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    Text("Hotels in \(location)")
                        .font(.title2).bold()
                        .padding(.horizontal)
                        .padding(.top, 8)

                    Text("Find the perfect stay for your trip")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    // Hotel Cards
                    ForEach(viewModel.hotels) { hotel in
                        NavigationLink(destination: HotelDetailView(hotel: hotel)) {
                            HotelCard(hotel: hotel)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Spacer()
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Available Hotels")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadHotels(for: location)
        }
    }
}

struct HotelCard: View {
    let hotel: Hotel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hotel Image
            Image(hotel.mainImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 180)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                // Hotel Name and Rating
                HStack {
                    Text(hotel.name)
                        .font(.headline)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)

                        Text(String(format: "%.1f", hotel.rating))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }

                // Hotel Address
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)

                    Text(hotel.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                // Price and Amenities
                HStack {
                    Text("₹\(hotel.price)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("per night")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    // Top 3 amenities
                    HStack(spacing: 8) {
                        ForEach(hotel.amenities.prefix(3), id: \.self) { amenity in
                            HStack(spacing: 2) {
                                Image(systemName: amenityIcon(for: amenity))
                                    .font(.caption2)

                                Text(amenity)
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                        }
                    }
                }
            }
            .padding(12)
            .background(Color(UIColor.secondarySystemGroupedBackground))
        }
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    // Helper to map amenities to icons
    private func amenityIcon(for amenity: String) -> String {
        switch amenity.lowercased() {
        case "wifi": return "wifi"
        case "restaurant": return "fork.knife"
        case "spa": return "sparkles"
        case "parking": return "car.fill"
        case "mountain view", "valley view": return "mountain.2.fill"
        case "room service": return "bell.fill"
        case "heated rooms": return "thermometer.sun.fill"
        case "meditation center": return "figure.mind.and.body"
        case "yoga classes": return "figure.yoga"
        case "organic restaurant": return "leaf.fill"
        case "library": return "book.fill"
        case "riverside dining": return "water.waves"
        case "adventure sports desk": return "figure.hiking"
        default: return "star.fill"
        }
    }
}

struct ErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text("Oops! Something went wrong")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}

struct EmptyStateView2: View {
    let message: String
    let icon: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.indigo.opacity(0.6))

            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}


struct HotelDetailView: View {
    let hotel: Hotel
    @State private var selectedRoom: Hotel.RoomType?
    @State private var checkInDate = Date()
    @State private var checkOutDate = Date().addingTimeInterval(86400 * 2) // 2 days later
    @State private var numberOfGuests = 2
    @State private var showBookingConfirmation = false

    private var nightCount: Int {
        Calendar.current.dateComponents([.day], from: checkInDate, to: checkOutDate).day ?? 0
    }

    private var totalPrice: Int {
        (selectedRoom?.price ?? hotel.price) * nightCount
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hotel Image
                Image(hotel.mainImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 220)
                    .clipped()

                // Hotel Name and Rating
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(hotel.name)
                            .font(.title2).bold()

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)

                            Text(String(format: "%.1f", hotel.rating))
                                .font(.headline)
                        }
                    }

                    // Location
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)

                        Text(hotel.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // Description
                Text(hotel.description)
                    .font(.body)
                    .padding(.horizontal)

                // Amenities
                VStack(alignment: .leading, spacing: 12) {
                    Text("Amenities")
                        .font(.headline)
                        .padding(.bottom, 4)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(hotel.amenities, id: \.self) { amenity in
                            HStack(spacing: 6) {
                                Image(systemName: amenityIcon(for: amenity))
                                    .foregroundColor(.indigo)

                                Text(amenity)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                // Booking Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Book Your Stay")
                        .font(.headline)

                    // Date Selection
                    VStack(spacing: 16) {
                        DatePicker("Check-in", selection: $checkInDate, displayedComponents: .date)

                        DatePicker("Check-out", selection: $checkOutDate, in: checkInDate..., displayedComponents: .date)

                        Stepper("Guests: \(numberOfGuests)", value: $numberOfGuests, in: 1...10)
                    }
                    .padding()
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .cornerRadius(12)

                    // Room Types
                    Text("Select Room Type")
                        .font(.headline)
                        .padding(.top, 8)

                    ForEach(hotel.roomTypes) { room in
                        RoomTypeCard(
                            room: room,
                            isSelected: selectedRoom?.id == room.id,
                            action: {
                                selectedRoom = room
                            }
                        )
                    }

                    if hotel.roomTypes.isEmpty {
                        HStack {
                            Image(systemName: "bed.double.fill")
                                .foregroundColor(.indigo)

                            Text("Standard Room")
                                .font(.headline)

                            Spacer()

                            Text("₹\(hotel.price)")
                                .font(.headline)
                        }
                        .padding()
                        .background(Color(UIColor.tertiarySystemGroupedBackground))
                        .cornerRadius(12)
                    }

                    // Price Summary
                    VStack(spacing: 8) {
                        HStack {
                            Text("Price per night")
                            Spacer()
                            Text("₹\(selectedRoom?.price ?? hotel.price)")
                        }

                        HStack {
                            Text("Number of nights")
                            Spacer()
                            Text("\(nightCount)")
                        }

                        Divider()

                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text("₹\(totalPrice)")
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)

                    // Book Now Button
                    Button(action: {
                        showBookingConfirmation = true
                        // Ensure profile data is available
                        if ProfileDetails.username.isEmpty {
                            // If username is not set, use hotel name as fallback
                            ProfileDetails.username = "Guest"
                        }
                    }) {
                        Text("Pay Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                // Reviews Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Guest Reviews")
                        .font(.headline)
                        .padding(.bottom, 4)

                    ForEach(hotel.reviews, id: \.id) { review in
                        ReviewCard2(review: review)
                    }

                    if hotel.reviews.isEmpty {
                        Text("No reviews yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer(minLength: 30)
            }
            .padding(.vertical)
        }
        .navigationTitle("Hotel Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showBookingConfirmation) {
            BookingConfirmationView(hotel: hotel, roomType: selectedRoom, checkInDate: checkInDate, checkOutDate: checkOutDate, numberOfGuests: numberOfGuests, totalAmount: totalPrice)
        }
    }

    // Helper to map amenities to icons
    private func amenityIcon(for amenity: String) -> String {
        switch amenity.lowercased() {
        case "wifi": return "wifi"
        case "restaurant": return "fork.knife"
        case "spa": return "sparkles"
        case "parking": return "car.fill"
        case "mountain view", "valley view": return "mountain.2.fill"
        case "room service": return "bell.fill"
        case "heated rooms": return "thermometer.sun.fill"
        case "meditation center": return "figure.mind.and.body"
        case "yoga classes": return "figure.yoga"
        case "organic restaurant": return "leaf.fill"
        case "library": return "book.fill"
        case "riverside dining": return "water.waves"
        case "adventure sports desk": return "figure.hiking"
        default: return "star.fill"
        }
    }
}

struct RoomTypeCard: View {
    let room: Hotel.RoomType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(room.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(room.name)
                        .font(.headline)

                    Text(room.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.indigo)

                        Text("Up to \(room.capacity) guests")
                            .font(.caption)
                            .foregroundColor(.indigo)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("₹\(room.price)")
                        .font(.headline)

                    Text("per night")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.indigo.opacity(0.1) : Color(UIColor.tertiarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.indigo : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ReviewCard2: View {
    let review: Hotel.Review

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.author)
                    .font(.headline)

                Spacer()

                HStack {
                    ForEach(0..<5) { index in
                        Image(systemName: index < review.rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }

            Text(review.comment)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(review.date)
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
        }
        .padding()
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

struct DetailRow2: View {
    let title: String
    let value: String
    var isHighlighted: Bool = false

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)

            Spacer()

            Text(value)
                .font(isHighlighted ? .headline : .subheadline)
                .foregroundColor(isHighlighted ? .primary : .primary)
                .fontWeight(isHighlighted ? .bold : .regular)
                .multilineTextAlignment(.trailing)
        }
    }
}

// Update BookingConfirmationView with booking functionality
struct BookingConfirmationView: View {
    let hotel: Hotel
    let roomType: Hotel.RoomType?
    let checkInDate: Date
    let checkOutDate: Date
    let numberOfGuests: Int
    let totalAmount: Int
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    @State private var isSubmittingBooking = false
    @State private var bookingSuccess = false
    @State private var errorMessage: String? = nil
    
    // Add API service for making booking requests
    private let apiService = APIService()
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Success Animation
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .padding(.bottom, 10)

                        Text("Booking Confirmed!")
                            .font(.title)
                            .fontWeight(.bold)
                            .opacity(isAnimating ? 1.0 : 0.0)

                        Text("You will be contacted shortly")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .opacity(isAnimating ? 1.0 : 0.0)
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 30)

                    // Booking Details
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Booking Details")
                            .font(.title2)
                            .fontWeight(.bold)

                        VStack(alignment: .leading, spacing: 16) {
                            DetailRow2(title: "Hotel", value: hotel.name)

                            DetailRow2(title: "Room Type", value: roomType?.name ?? "Standard Room")

                            DetailRow2(title: "Check-in", value: checkInDate.formatted(date: .long, time: .omitted))

                            DetailRow2(title: "Check-out", value: checkOutDate.formatted(date: .long, time: .omitted))

                            DetailRow2(title: "Guests", value: "\(numberOfGuests)")

                            DetailRow2(title: "Total Amount", value: "₹\(totalAmount)", isHighlighted: true)

                            DetailRow2(title: "Booking ID", value: generateBookingID())
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Contact Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Contact Information")
                            .font(.headline)

                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.indigo)

                            Text(hotel.contactPhone)
                                .font(.subheadline)
                        }

                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.indigo)

                            Text(hotel.contactEmail)
                                .font(.subheadline)
                        }

                        Text("For any queries or changes to your booking, please contact the hotel directly using the details above.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.indigo)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Booking Confirmation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onAppear {
                // Submit booking to server when view appears
                submitBooking()
                
                // Show animation
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                    isAnimating = true
                }
            }
        }
    }

    // Generate a random booking ID
    private func generateBookingID() -> String {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
        let numbers = "123456789"

        var id = "BK-"

        for _ in 0..<2 {
            id.append(letters.randomElement()!)
        }

        for _ in 0..<4 {
            id.append(numbers.randomElement()!)
        }

        return id
    }
    
    // Submit booking data to server
    private func submitBooking() {
        isSubmittingBooking = true
        
        // Create booking data dictionary with required fields
        let bookingData: [String: Any] = [
            "id": 5, // Set ID to 5 as specified
            "username": ProfileDetails.username,
            "contact": ProfileDetails.contact.isEmpty ? "N/A" : ProfileDetails.contact,
            "gender": ProfileDetails.gender.isEmpty ? "N/A" : ProfileDetails.gender,
            "nationality": ProfileDetails.nationality.isEmpty ? "N/A" : ProfileDetails.nationality,
            "domicile": ProfileDetails.domicile.isEmpty ? "N/A" : ProfileDetails.domicile,
            "price": totalAmount,
            "checkIn": checkInDate.formatted(date: .long, time: .omitted),
            "checkOut": checkOutDate.formatted(date: .long, time: .omitted),
            "roomType": roomType?.name ?? "Standard Room",
            "Guests": numberOfGuests,
            "roomAlloted": "no" // Set to "no" as specified
        ]
        
        // Print booking data for debugging
        print("Submitting booking: \(bookingData)")
        
        // Submit booking data to server
        apiService.submitBooking(bookingData: bookingData)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isSubmittingBooking = false
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        errorMessage = "Failed to save booking: \(error.localizedDescription)"
                        print("Error submitting booking: \(error)")
                    }
                },
                receiveValue: { response in
                    print("Booking response: \(response)")
                    bookingSuccess = response.success
                    
                    if !response.success {
                        errorMessage = response.message ?? "Unknown error occurred"
                    }
                }
            )
            .store(in: &cancellables)
    }
}
// MARK: - Plan Tab View

struct PlanView: View {
    @EnvironmentObject private var tripPlanner: TripPlannerViewModel
    @State private var startDestination = ""
    @State private var endDestination = ""
    @State private var startDate = Date()
    @State private var endDate: Date
    @State private var selectedInterests: Set<TravelInterest> = []
    @State private var showItinerary = false

    // Initialize endDate based on initial startDate
    init() {
        _endDate = State(initialValue: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date())
    }

    var isFormValid: Bool {
        !startDestination.isEmpty && !endDestination.isEmpty && !selectedInterests.isEmpty && endDate >= startDate
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Header Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("himachal_background")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .cornerRadius(15)

                        VStack(alignment: .leading, spacing: 5) {
                            Text("Plan Your Himachal Adventure")
                                .font(.title2).bold()
                                .foregroundColor(.white)

                            Text("Create a personalized journey through the mountains")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal)

                    // MARK: - Destinations Section
                    PlanSectionHeader(title: "Where To?", icon: "map.fill")

                    VStack(spacing: 12) {
                        PlanTextFieldCard(
                            iconName: "mappin.circle.fill",
                            placeholder: "Starting Point (e.g., Shimla)",
                            text: $startDestination
                        )

                        PlanTextFieldCard(
                            iconName: "mappin.and.ellipse",
                            placeholder: "Final Destination (e.g., Manali)",
                            text: $endDestination
                        )
                    }
                    .padding(.horizontal)

                    // MARK: - Travel Dates Section
                    PlanSectionHeader(title: "When?", icon: "calendar")

                    VStack(spacing: 12) {
                        DatePickerCard(title: "Start Date", selection: $startDate)
                        DatePickerCard(title: "End Date", selection: $endDate, minDate: startDate)
                    }
                    .padding(.horizontal)

                    // MARK: - Interest Section with Horizontal Scrolling Chips
                    PlanSectionHeader(title: "Your Interests", icon: "heart.fill")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(TravelInterest.allCases) { interest in
                                InterestChip(
                                    interest: interest,
                                    isSelected: selectedInterests.contains(interest),
                                    toggleAction: {
                                        if selectedInterests.contains(interest) {
                                            selectedInterests.remove(interest)
                                        } else {
                                            selectedInterests.insert(interest)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }

                    // MARK: - Generate Button
                    VStack {
                        Button {
                            hideKeyboard()
                            if isFormValid {
                                tripPlanner.generateItinerary(
                                    startDestination: startDestination,
                                    endDestination: endDestination,
                                    startDate: startDate,
                                    endDate: endDate,
                                    interests: Array(selectedInterests)
                                )
                                showItinerary = true
                            }
                        } label: {
                            HStack(spacing: 12) {
                                if tripPlanner.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                        .font(.headline)
                                }
                                Text("Generate My Yatra")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(.indigo)
                        .disabled(!isFormValid || tripPlanner.isLoading)
                        .padding(.horizontal)
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)

                        if let errorMessage = tripPlanner.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .padding(.top, 15)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Plan Your Trip")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                                    Image(systemName: "mountain.2.fill")
                                        .foregroundColor(.indigo)
                                }
                            }
                            .navigationDestination(isPresented: $showItinerary) {
                                ItineraryView()
                            }
                            .onTapGesture {
                                hideKeyboard()
                            }
                        }
                    }
                }

                // MARK: - Supporting Views for Plan Page

                struct PlanSectionHeader: View {
                    let title: String
                    let icon: String

                    var body: some View {
                        HStack(spacing: 10) {
                            Image(systemName: icon)
                                .foregroundColor(.indigo)
                                .imageScale(.medium)

                            Text(title)
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                    }
                }

                struct PlanTextFieldCard: View {
                    let iconName: String
                    let placeholder: String
                    @Binding var text: String

                    var body: some View {
                        HStack(spacing: 12) {
                            Image(systemName: iconName)
                                .foregroundColor(.indigo)
                                .frame(width: 24)

                            TextField(placeholder, text: $text)
                                .padding(.vertical, 12)
                        }
                        .padding(.horizontal, 16)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }

                struct DatePickerCard: View {
                    let title: String
                    @Binding var selection: Date
                    var minDate: Date?

                    var body: some View {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.indigo)
                                .frame(width: 24)

                            if let minDate = minDate {
                                DatePicker(title, selection: $selection, in: minDate..., displayedComponents: .date)
                                    .padding(.vertical, 10)
                            } else {
                                DatePicker(title, selection: $selection, displayedComponents: .date)
                                    .padding(.vertical, 10)
                            }
                        }
                        .padding(.horizontal, 16)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }

                // MARK: - Interest Chip View (Horizontally Scrolling)

                struct InterestChip: View {
                    let interest: TravelInterest
                    let isSelected: Bool
                    let toggleAction: () -> Void

                    var body: some View {
                        Button(action: toggleAction) {
                            HStack(spacing: 6) {
                                Image(systemName: interest.icon)
                                    .foregroundColor(isSelected ? .white : .indigo)
                                    .imageScale(.small)

                                Text(interest.rawValue.capitalized)
                                    .font(.subheadline)
                                    .fontWeight(isSelected ? .semibold : .medium)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(isSelected ? Color.indigo : Color(UIColor.secondarySystemGroupedBackground))
                            .foregroundColor(isSelected ? .white : .primary)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(isSelected ? Color.indigo : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: isSelected ? Color.indigo.opacity(0.3) : Color.clear, radius: 3, x: 0, y: 1)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }

                // Add subtle scale animation to chips
                struct ScaleButtonStyle: ButtonStyle {
                    func makeBody(configuration: Configuration) -> some View {
                        configuration.label
                            .scaleEffect(configuration.isPressed ? 0.96 : 1)
                            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
                    }
                }

                // MARK: - Itinerary List View

// MARK: - Itinerary List View

struct ItineraryView: View {
    @EnvironmentObject private var tripPlanner: TripPlannerViewModel
    @State private var selectedDay: ItineraryDay? = nil
    @State private var selectedDayNumber: Int = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Journey Overview Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Himachal Journey")
                            .font(.title2).bold()

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.indigo)
                                        .imageScale(.small)

                                    Text("From:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    Text(tripPlanner.startDestination ?? "N/A")
                                        .font(.subheadline).bold()
                                }

                                HStack {
                                    Image(systemName: "location.circle.fill")
                                        .foregroundColor(.indigo)
                                        .imageScale(.small)

                                    Text("To:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    Text(tripPlanner.endDestination ?? "N/A")
                                        .font(.subheadline).bold()
                                }
                            }

                            Spacer()

                            if let start = tripPlanner.startDate, let end = tripPlanner.endDate {
                                VStack(alignment: .trailing, spacing: 4) {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.indigo)
                                            .imageScale(.small)

                                        Text(start.formatted(date: .abbreviated, time: .omitted))
                                            .font(.subheadline)
                                    }

                                    HStack {
                                        Image(systemName: "calendar.badge.clock")
                                            .foregroundColor(.indigo)
                                            .imageScale(.small)

                                        Text(end.formatted(date: .abbreviated, time: .omitted))
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }

                        if let start = tripPlanner.startDate, let end = tripPlanner.endDate {
                            let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0

                            HStack {
                                Label("\(days + 1) Days", systemImage: "clock.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.indigo.opacity(0.1))
                                    .cornerRadius(8)

                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)

                    // Itinerary Days Section
                    if tripPlanner.isLoading {
                        LoadingView(message: "Generating Itinerary...")
                    } else if tripPlanner.itineraryDays.isEmpty {
                        EmptyStateView(message: "No itinerary generated yet. Please go back and provide your trip details.")
                    } else {
                        Text("Daily Itinerary")
                            .font(.title3).bold()
                            .padding(.horizontal)
                            .padding(.top, 5)

                        VStack(spacing: 16) {
                            ForEach(Array(tripPlanner.itineraryDays.enumerated()), id: \.element.id) { index, day in
                                VStack(spacing: 8) {
                                    // Day card with navigation
                                    NavigationLink(destination: ItineraryDayDetailView(day: day, dayNumber: index + 1)) {
                                        ItineraryDayCardContent(day: day, dayNumber: index + 1)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(15)
                                    .contentShape(Rectangle()) // <<< Added

                                    // Hotels button - using NavigationLink instead of Button
                                    NavigationLink(destination: HotelListView(location: day.mainLocation)) {
                                        HotelsAvailableButtonContent(location: day.mainLocation)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .contentShape(Rectangle()) // <<< Added
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Your Itinerary")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Keep the dummy data fetch for testing if needed
                #if DEBUG
                if tripPlanner.itineraryDays.isEmpty && !tripPlanner.isLoading {
                    print("DEBUG: Fetching dummy itinerary.")
                    tripPlanner.fetchDummyItinerary()
                }
                #endif
            }
        }
    }
}

// Separate the hotel button content from its action
struct HotelsAvailableButtonContent: View {
    let location: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bed.double.fill")
                .foregroundColor(.orange)
                .imageScale(.medium)

            Text("Hotels in \(location)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

                // Separate card content without any button functionality
                struct ItineraryDayCardContent: View {
                    let day: ItineraryDay
                    let dayNumber: Int

                    var body: some View {
                        VStack(alignment: .leading, spacing: 12) {
                            // Image with header overlay
                            ZStack(alignment: .bottomLeading) {
                                Image(day.mainImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))

                                // Gradient overlay for better text visibility
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .frame(height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 15))

                                // Day badge and location
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Day \(dayNumber)")
                                            .font(.caption).bold()
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Capsule().fill(Color.blue))
                                            .foregroundColor(.white)

                                        Text("•")
                                            .foregroundColor(.white)

                                        Text(day.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption).bold()
                                            .foregroundColor(.white)

                                        Spacer()

                                        if day.hasWeatherAlert {
                                            Image(systemName: day.weatherAlert?.icon ?? "exclamationmark.triangle.fill")
                                                .foregroundColor(.orange)
                                                .padding(8)
                                                .background(Circle().fill(Color.white.opacity(0.2)))
                                        }
                                    }

                                    Text(day.mainLocation)
                                        .font(.title3).bold()
                                        .foregroundColor(.white)
                                        .shadow(radius: 1)
                                }
                                .padding(12)
                            }

                            // Highlights
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Highlights")
                                    .font(.headline)
                                    .foregroundColor(.indigo)

                                ForEach(day.highlights.prefix(3), id: \.self) { highlight in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .imageScale(.small)
                                            .padding(.top, 2)

                                        Text(highlight)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                }

                                if day.highlights.count > 3 {
                                    Text("+ \(day.highlights.count - 3) more")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 24)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        }
                    }
                }

                // Separate Hotels Available button component
                struct HotelsAvailableButton: View {
                    let location: String
                    let action: () -> Void

                    var body: some View {
                        Button(action: action) {
                            HStack(spacing: 8) {
                                Image(systemName: "bed.double.fill")
                                    .foregroundColor(.orange)
                                    .imageScale(.medium)

                                Text("Hotels in \(location)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                // MARK: - Supporting Views for Itinerary

                struct LoadingView: View {
                    let message: String

                    var body: some View {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)

                            Text(message)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 80)
                    }
                }

                struct EmptyStateView: View {
                    let message: String

                    var body: some View {
                        VStack(spacing: 15) {
                            Image(systemName: "map")
                                .font(.system(size: 50))
                                .foregroundColor(.indigo.opacity(0.6))

                            Text(message)
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 80)
                    }
                }

                // MARK: - Itinerary Day Detail View

                struct ItineraryDayDetailView: View {
                    let day: ItineraryDay
                    let dayNumber: Int
                    @State private var selectedSection: ItinerarySection = .attractions

                    enum ItinerarySection: String, CaseIterable, Identifiable {
                        case attractions = "Attractions"
                        case food = "Food"
                        case activities = "Activities"
                        case alerts = "Alerts"
                        case notes = "Notes"

                        var id: String { self.rawValue }

                        var systemImage: String {
                            switch self {
                            case .attractions: "mappin.and.ellipse"
                            case .food: "fork.knife"
                            case .activities: "figure.walk"
                            case .alerts: "exclamationmark.triangle.fill"
                            case .notes: "note.text"
                            }
                        }
                    }

                    var body: some View {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                // Header Image with Overlay
                                ZStack(alignment: .bottom) {
                                    Image(day.mainImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 250)
                                        .clipped()

                                    // Gradient overlay for better text visibility
                                    LinearGradient(
                                        gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                                        startPoint: .bottom,
                                        endPoint: .center
                                    )
                                    .frame(height: 120)

                                    // Location and Date
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(day.mainLocation)
                                            .font(.largeTitle).bold()
                                            .foregroundColor(.white)
                                            .shadow(radius: 2)

                                        HStack {
                                            Text(day.date.formatted(date: .long, time: .omitted))
                                                .font(.headline)
                                                .foregroundColor(.white.opacity(0.9))
                                                .shadow(radius: 1)

                                            if let altitude = day.altitude {
                                                Text("•")
                                                    .foregroundColor(.white.opacity(0.7))

                                                Label("\(altitude)m", systemImage: "mountain.2.fill")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white.opacity(0.9))
                                                    .shadow(radius: 1)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 15)
                                }

                                // Map Snippet
                                MapSnippet(location: day.locationCoordinate, locationName: day.mainLocation)
                                    .frame(height: 180)
                                    .cornerRadius(15)
                                    .padding(.horizontal)

                                // Section Picker
                                Picker("Details", selection: $selectedSection) {
                                    ForEach(ItinerarySection.allCases) { section in
                                        Label(section.rawValue, systemImage: section.systemImage)
                                            .tag(section)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal)

                                // Section Content
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: selectedSection.systemImage)
                                            .foregroundColor(.indigo)

                                        Text(selectedSection.rawValue)
                                            .font(.title2).bold()
                                    }
                                    .padding(.bottom, 10)

                                    switch selectedSection {
                                    case .attractions:
                                        AttractionsSection(attractions: day.attractions)
                                    case .food:
                                        FoodSection(recommendations: day.foodRecommendations)
                                    case .activities:
                                        ActivitiesSection(activities: day.activities)
                                    case .alerts:
                                        AlertsSection(weatherAlert: day.weatherAlert, roadAlerts: day.roadAlerts)
                                    case .notes:
                                        NotesSection(dayId: day.id)
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(15)
                                .padding(.horizontal)

                                Spacer(minLength: 20)
                            }
                        }
                        .navigationTitle("Day \(dayNumber)")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    // Edit/Customize day functionality
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                            }
                        }
                        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                    }
                }

                // MARK: - Detail View Sub-Sections

                struct MapSnippet: View {
                    let location: CLLocationCoordinate2D
                    let locationName: String

                    var body: some View {
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [.blue.opacity(0.3), .green.opacity(0.3)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )

                            VStack {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.bottom, 5)

                                Text(locationName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)

                                Text("(\(String(format: "%.3f", location.latitude)), \(String(format: "%.3f", location.longitude)))")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                                    .shadow(radius: 1)
                            }
                            .padding()
                        }
                    }
                }

                // MARK: - Section Content Views

                struct AttractionsSection: View {
                    let attractions: [Attraction]

                    var body: some View {
                        if attractions.isEmpty {
                            Text("No specific attractions listed for this day.")
                                .foregroundColor(.secondary)
                                .padding(.vertical)
                        } else {
                            VStack(alignment: .leading, spacing: 18) {
                                ForEach(attractions) { attraction in
                                    AttractionRow(attraction: attraction)

                                    if attraction.id != attractions.last?.id {
                                        Divider()
                                            .padding(.leading, 95)
                                    }
                                }
                            }
                        }
                    }
                }

                struct AttractionRow: View {
                    let attraction: Attraction

                    var body: some View {
                        HStack(alignment: .top, spacing: 15) {
                            Image(attraction.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                                .clipped()

                            VStack(alignment: .leading, spacing: 5) {
                                Text(attraction.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text(attraction.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)

                                HStack(spacing: 15) {
                                    Label(attraction.bestTimeToVisit, systemImage: "clock")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    if let difficulty = attraction.difficulty {
                                        Label(difficulty.rawValue, systemImage: "figure.hiking")
                                            .font(.caption)
                                            .foregroundColor(difficulty.color)
                                    }
                                }
                                .padding(.top, 2)
                            }

                            Spacer()
                        }
                    }
                }

                struct FoodSection: View {
                    let recommendations: [FoodRecommendation]

                    var body: some View {
                        if recommendations.isEmpty {
                            Text("No specific food recommendations for this day.")
                                .foregroundColor(.secondary)
                                .padding(.vertical)
                        } else {
                            VStack(alignment: .leading, spacing: 18) {
                                ForEach(recommendations) { food in
                                    FoodRow(food: food)

                                    if food.id != recommendations.last?.id {
                                        Divider()
                                            .padding(.leading, 95)
                                    }
                                }
                            }
                        }
                    }
                }

                struct FoodRow: View {
                    let food: FoodRecommendation

                    var body: some View {
                        HStack(alignment: .top, spacing: 15) {
                            Image(food.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                                .clipped()

                            VStack(alignment: .leading, spacing: 5) {
                                Text(food.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text(food.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)

                                if !food.tags.isEmpty {
                                    HStack {
                                        ForEach(food.tags.prefix(3), id: \.self) { tag in
                                            Text(tag)
                                                .font(.caption2)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(Capsule().fill(Color.green.opacity(0.2)))
                                                .foregroundColor(.green.opacity(0.9))
                                        }
                                    }
                                    .padding(.top, 2)
                                }

                                if let place = food.bestPlace {
                                    Label("Try at: \(place)", systemImage: "mappin.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 2)
                                }
                            }

                            Spacer()
                        }
                    }
                }

                struct ActivitiesSection: View {
                    let activities: [Activity]

                    var body: some View {
                        if activities.isEmpty {
                            Text("No specific activities listed for this day.")
                                .foregroundColor(.secondary)
                                .padding(.vertical)
                        } else {
                            VStack(alignment: .leading, spacing: 15) {
                                ForEach(activities) { activity in
                                    ActivityCard(activity: activity)
                                }
                            }
                        }
                    }
                }

                struct ActivityCard: View {
                    let activity: Activity

                    var body: some View {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: activity.icon)
                                    .font(.title3)
                                    .foregroundColor(.indigo)
                                    .frame(width: 30, alignment: .center)

                                Text(activity.name)
                                    .font(.headline)

                                Spacer()

                                if let difficulty = activity.difficulty {
                                    DifficultyBadge(difficulty: difficulty)
                                }
                            }

                            Text(activity.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if let duration = activity.duration {
                                Label("Duration: \(duration)", systemImage: "hourglass")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 2)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.tertiarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                }

                struct DifficultyBadge: View {
                    let difficulty: Difficulty

                    var body: some View {
                        Text(difficulty.rawValue)
                            .font(.caption).bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(difficulty.color.opacity(0.15))
                            .foregroundColor(difficulty.color)
                            .clipShape(Capsule())
                    }
                }

                struct AlertsSection: View {
                    let weatherAlert: WeatherAlert?
                    let roadAlerts: [RoadAlert]

                    var body: some View {
                        VStack(alignment: .leading, spacing: 15) {
                            if weatherAlert == nil && roadAlerts.isEmpty {
                                Label("No travel advisories reported for this area.", systemImage: "checkmark.seal.fill")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .padding(.vertical)
                            } else {
                                if let alert = weatherAlert {
                                    AlertCard(
                                        title: alert.type,
                                        description: alert.description,
                                        icon: alert.icon,
                                        color: .orange
                                    )
                                }

                                ForEach(roadAlerts) { alert in
                                    AlertCard(
                                        title: "Road: \(alert.road) (\(alert.status.rawValue))",
                                        description: alert.description,
                                        icon: alert.status.icon,
                                        color: alert.status.color
                                    )
                                }
                            }
                        }
                    }
                }

                struct AlertCard: View {
                    let title: String
                    let description: String
                    let icon: String
                    let color: Color

                    var body: some View {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundColor(color)
                                .frame(width: 30, alignment: .center)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(title)
                                    .font(.headline)
                                    .foregroundColor(color)

                                Text(description)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }

                            Spacer()
                        }
                        .padding()
                        .background(color.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.3), lineWidth: 1))
                    }
                }

                struct NotesSection: View {
                    let dayId: String
                    @State private var note: String = ""

                    var body: some View {
                        VStack(alignment: .leading, spacing: 15) {
                            TextEditor(text: $note)
                                .frame(minHeight: 150, maxHeight: 300)
                                .padding(8)
                                .background(Color(UIColor.tertiarySystemBackground))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                .font(.body)

                            Button {
                                hideKeyboard()
                                // Save note implementation would go here
                            } label: {
                                Label("Save Note", systemImage: "square.and.arrow.down")
                            }
                            .buttonStyle(.bordered)
                            .tint(.indigo)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }

                // MARK: - Keyboard Helper

                extension View {
                    func hideKeyboard() {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
