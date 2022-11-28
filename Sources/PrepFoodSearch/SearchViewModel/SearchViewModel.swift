import SwiftUI
import PrepDataTypes
import SwiftSugar

public class SearchViewModel: ObservableObject {
    
    public static let shared = SearchViewModel()
    @Published var searchText: String = ""
    @Published var foodType: FoodType = .food

    /// Recently used foods (or added) foods that are populated and kept up-to-date so they're always ready when the user presents this
    @Published var recents: [Food] = []
    @Published var allMyFoods: [Food] = []
    
    @Published var myFoodResults: FoodSearchResults = FoodSearchResults(isLoading: true, foods: [])
    @Published var verifiedResults: FoodSearchResults = FoodSearchResults()
    @Published var datasetResults: FoodSearchResults = FoodSearchResults()
    
    //MARK: - Legacy
    
    @Published var results = [FoodSearchResult]()
    
    @Published var isLoadingPage = false
    var currentPage = 1
    var canLoadMorePages = true
    
    public init(recents: [Food] = [], allMyFoods: [Food] = []) {
        self.recents = recents
        self.allMyFoods = allMyFoods
    }
    
    public func setScopeAsLoading(_ scope: SearchScope) {
        switch scope {
        case .backend:
            /// Don't show loading indicator if we're searching the backend while we already have results
            /// (since this mostly happens during text entry, and we wouldn't want to constantly keep
            /// swapping the view)
            break
        case .verified:
            verifiedResults.isLoading = true
            verifiedResults.foods = []
        case .datasets:
            datasetResults.isLoading = true
            datasetResults.foods = []
        }
    }
    
    public func completeScope(_ scope: SearchScope, with foods: [Food], haveMoreResults: Bool) {
        switch scope {
        case .backend:
            myFoodResults.foods = foods
            myFoodResults.isLoading = false
            myFoodResults.canLoadMorePages = haveMoreResults
        case .verified:
            verifiedResults.foods = foods
            verifiedResults.isLoading = false
            verifiedResults.canLoadMorePages = haveMoreResults
        case .datasets:
            datasetResults.foods = foods
            datasetResults.isLoading = false
            datasetResults.canLoadMorePages = haveMoreResults
        }
    }
    
    public func results(for scope: SearchScope) -> FoodSearchResults {
        switch scope {
        case .backend:
            return myFoodResults
        case .verified:
            return verifiedResults
        case .datasets:
            return datasetResults
        }
    }
    
    public func loadMoreResults(for scope: SearchScope) {
        switch scope {
        case .backend:
            myFoodResults.isLoading = true
        case .verified:
            verifiedResults.isLoading = true
        case .datasets:
            datasetResults.isLoading = true
        }
    }
    
    func clearSearch() {
        verifiedResults.clear()
        datasetResults.clear()
        
        myFoodResults.clear()
        myFoodResults.foods = []
        myFoodResults.isLoading = true
    }
    
    /// We determine this by examining the `FoodSearcResults` for both verified and datasets, and if they are both nil,
    /// we can conclude that the user hasn't submitted search yet (as they begin as nil and then get assigned empty arrays at least)
    var hasNotSubmittedSearchYet: Bool {
        verifiedResults.foods == nil && datasetResults.foods == nil
    }
    
    var hasResults: Bool {
        myFoodResults.foods?.isEmpty == false
        || verifiedResults.foods?.isEmpty == false
        || datasetResults.foods?.isEmpty == false
    }
}

extension FoodSearchResults {
    mutating func clear() {
        foods = nil
        currentPage = 1
        canLoadMorePages = true
        isLoading = false
    }
}
