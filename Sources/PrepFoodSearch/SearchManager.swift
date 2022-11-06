import SwiftUI
import PrepDataTypes
import SwiftSugar

struct SearchResults {
    var isLoading: Bool = false
    var foods: [Food] = []
    
    var isLoadingPage = false
    var currentPage = 1
    var canLoadMorePages = true
}

public class SearchManager: ObservableObject {
    
    public static let shared = SearchManager()
    @Published var searchText: String = ""
    @Published var foodType: FoodType = .food

    /// Recently used foods (or added) foods that are populated and kept up-to-date so they're always ready when the user presents this
    @Published var recents: [Food] = []
    @Published var allMyFoods: [Food] = []
    
    @Published var myFoodResults: SearchResults = SearchResults()
    @Published var verifiedResults: SearchResults = SearchResults()
    @Published var datasetResults: SearchResults = SearchResults()

    //MARK: - Legacy
    
    @Published var results = [FoodSearchResult]()
    
    @Published var isLoadingPage = false
    var currentPage = 1
    var canLoadMorePages = true
    
    public init(recents: [Food] = [], allMyFoods: [Food] = []) {
        self.recents = recents
        self.allMyFoods = allMyFoods
    }
}
