import SwiftUI
import Combine
import CoreLocation

class TripPlannerViewModel: ObservableObject {
    @Published var startDestination: String?
    @Published var endDestination: String?
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var selectedInterests: [TravelInterest] = []
    @Published var itineraryDays: [ItineraryDay] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let apiService = APIService()
    private var cancellables = Set<AnyCancellable>()
    
    func generateItinerary(startDestination: String, endDestination: String, startDate: Date, endDate: Date, interests: [TravelInterest]) {
        self.startDestination = startDestination
        self.endDestination = endDestination
        self.startDate = startDate
        self.endDate = endDate
        self.selectedInterests = interests
        
        isLoading = true
        itineraryDays = []
        
        let requestData: [String: Any] = [
            "startDestination": startDestination,
            "endDestination": endDestination,
            "startDate": ISO8601DateFormatter().string(from: startDate),
            "endDate": ISO8601DateFormatter().string(from: endDate),
            "interests": interests.map { $0.rawValue }
        ]
        
        apiService.postRequest(endpoint: "generate_itinerary", body: requestData)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] (response: APIResponse<[ItineraryDay]>) in
                self?.itineraryDays = response.data
            })
            .store(in: &cancellables)
    }
    
    // For testing without server
    func fetchDummyItinerary() {
        apiService.getRequest(endpoint: "itinerary")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] (response: APIResponse<[ItineraryDay]>) in
                self?.itineraryDays = response.data
            })
            .store(in: &cancellables)
    }
}

class UserProfileViewModel: ObservableObject {
    @Published var name = "Mountain Explorer"
    @Published var profileImage = "user_profile"
    @Published var totalVisits = 0
    @Published var collectedStamps: [PassportStamp] = []
    @Published var journeys: [Journey] = []
    @Published var contributions: [Contribution] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let apiService = APIService()
    private var cancellables = Set<AnyCancellable>()
    
    func loadUserProfile() {
        isLoading = true
        
        apiService.getRequest(endpoint: "user_profile")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] (response: APIResponse<UserProfileData>) in
                self?.name = response.data.name
                self?.profileImage = response.data.profileImage
                self?.totalVisits = response.data.totalVisits
                self?.collectedStamps = response.data.collectedStamps
                self?.journeys = response.data.journeys
                self?.contributions = response.data.contributions
            })
            .store(in: &cancellables)
    }
    
    struct UserProfileData: Codable {
        let name: String
        let profileImage: String
        let totalVisits: Int
        let collectedStamps: [PassportStamp]
        let journeys: [Journey]
        let contributions: [Contribution]
    }
}

class DiscoverViewModel: ObservableObject {
    @Published var hiddenGems: [HiddenGem] = []
    @Published var localGuides: [LocalGuide] = []
    @Published var festivals: [Festival] = []
    @Published var communityStories: [CommunityStory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let apiService = APIService()
    private var cancellables = Set<AnyCancellable>()
    
    func loadDiscoverData() {
        isLoading = true
        
        let hiddenGemsPublisher = apiService.getRequest(endpoint: "hidden_gems")
            .map { (response: APIResponse<[HiddenGem]>) -> [HiddenGem] in
                response.data
            }
        
        let guidesPublisher = apiService.getRequest(endpoint: "local_guides")
            .map { (response: APIResponse<[LocalGuide]>) -> [LocalGuide] in
                response.data
            }
        
        let festivalsPublisher = apiService.getRequest(endpoint: "festivals")
            .map { (response: APIResponse<[Festival]>) -> [Festival] in
                response.data
            }
        
        let storiesPublisher = apiService.getRequest(endpoint: "community_stories")
            .map { (response: APIResponse<[CommunityStory]>) -> [CommunityStory] in
                response.data
            }
        
        Publishers.Zip4(
            hiddenGemsPublisher,
            guidesPublisher,
            festivalsPublisher,
            storiesPublisher
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { [weak self] gems, guides, festivals, stories in
                self?.hiddenGems = gems
                self?.localGuides = guides
                self?.festivals = festivals
                self?.communityStories = stories
            }
        )
        .store(in: &cancellables)
    }
}

class LocationManager: ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 31.1048, longitude: 77.1734) // Default to Shimla
    
    // In a real app, this would use CLLocationManager to get actual user location
    private let locationManager = CLLocationManager()
    
    init() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Configure the location manager delegate to update currentLocation
        // Not implemented here for brevity
    }
}
