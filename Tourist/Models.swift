import SwiftUI
import CoreLocation

// MARK: - Enums

enum MapType {
    case standard, satellite
}

enum TravelInterest: String, CaseIterable, Identifiable, Codable {
    case adventure, religious, nature, cultural, hiddenGems = "hidden gems", foodie, relax
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .adventure: return "figure.hiking"
        case .religious: return "building.columns"
        case .nature: return "leaf"
        case .cultural: return "theatermasks"
        case .hiddenGems: return "sparkles"
        case .foodie: return "fork.knife"
        case .relax: return "bed.double"
        }
    }
}

enum Difficulty: String, Codable {
    case easy = "Easy"
    case moderate = "Moderate"
    case challenging = "Challenging"
    case expert = "Expert"
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .moderate: return .blue
        case .challenging: return .orange
        case .expert: return .red
        }
    }
}

enum RoadStatus: String, Codable {
    case open = "Open"
    case caution = "Caution"
    case closed = "Closed"
    
    var icon: String {
        switch self {
        case .open: return "checkmark.circle"
        case .caution: return "exclamationmark.triangle"
        case .closed: return "xmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .open: return .green
        case .caution: return .orange
        case .closed: return .red
        }
    }
}

enum JourneyStatus: String, Codable {
    case upcoming = "Upcoming"
    case ongoing = "Ongoing"
    case completed = "Completed"
    
    var color: Color {
        switch self {
        case .upcoming: return .blue
        case .ongoing: return .green
        case .completed: return .purple
        }
    }
}

// MARK: - Data Models

struct ItineraryDay: Identifiable, Codable {
    let id: String
    let date: Date
    let mainLocation: String
    let mainImage: String
    let highlights: [String]
    let altitude: Int?
    // We need to handle coordinate conversion for Codable
    var locationLatitude: Double
    var locationLongitude: Double
    let hasWeatherAlert: Bool
    let weatherAlert: WeatherAlert?
    let roadAlerts: [RoadAlert]
    let attractions: [Attraction]
    let foodRecommendations: [FoodRecommendation]
    let activities: [Activity]
    
    // Computed property to get CLLocationCoordinate2D
    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: locationLatitude, longitude: locationLongitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, mainLocation, mainImage, highlights, altitude
        case locationLatitude, locationLongitude, hasWeatherAlert
        case weatherAlert, roadAlerts, attractions, foodRecommendations, activities
    }
}

struct WeatherAlert: Identifiable, Codable {
    let id: String
    let type: String
    let description: String
    let icon: String
}

struct RoadAlert: Identifiable, Codable {
    let id: String
    let road: String
    let description: String
    let status: RoadStatus
}

struct Attraction: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let image: String
    let bestTimeToVisit: String
    let difficulty: Difficulty?
}

struct FoodRecommendation: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let image: String
    let tags: [String]
    let bestPlace: String?
}

struct Activity: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let difficulty: Difficulty?
    let duration: String?
}

struct HiddenGem: Identifiable, Codable {
    let id: String
    let name: String
    let location: String
    let image: String
    let visitors: Int
    let rating: Double
}

struct LocalGuide: Identifiable, Codable {
    let id: String
    let name: String
    let profileImage: String
    let specialty: [String]
    let languages: [String]
    let rating: Double
    let reviewCount: Int
    let yearsExperience: Int
    let regions: [String]
    let bio: String
    let reviews: [Review]
}

struct Review: Identifiable, Codable {
    let id: String
    let userName: String
    let userImage: String
    let rating: Int
    let date: Date
    let comment: String
}

struct Festival: Identifiable, Codable {
    let id: String
    let name: String
    let location: String
    let image: String
    let date: Date
    let description: String
    
    var isSoon: Bool {
        let calendar = Calendar.current
        let now = Date()
        let dateComponents = calendar.dateComponents([.day], from: now, to: date)
        return date > now && dateComponents.day ?? 0 < 30
    }
    
    // We exclude isSoon from Codable since it's computed
    enum CodingKeys: String, CodingKey {
        case id, name, location, image, date, description
    }
}

struct CommunityStory: Identifiable, Codable {
    let id: String
    let title: String
    let excerpt: String
    let image: String
    let author: String
    let authorImage: String
    let date: Date
}

struct PassportStamp: Identifiable, Codable {
    let id: String
    let location: String
    let icon: String
    let date: Date
}

struct Journey: Identifiable, Codable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let waypoints: [String]
    let status: JourneyStatus
}

struct Contribution: Identifiable, Codable {
    let id: String
    let location: String
    let description: String
    let image: String
    let date: Date
}

// MARK: - API Response Models

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T
    let message: String?
}

struct BookingData: Codable {
    let username: String
    let contact: String
    let price: Int
    let checkIn: String
    let checkOut: String
    let gender: String
    let nationality: String
    let domicile: String
    let roomType: String
    let Guests: Int
    let roomAlloted: String
}
