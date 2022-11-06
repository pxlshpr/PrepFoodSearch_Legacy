import SwiftUI
import PrepDataTypes

public class SearchManager: ObservableObject {
    
    public static let shared = SearchManager()
    @Published var searchText: String = ""
    @Published var foodType: FoodType = .food

    /// Recently used foods (or added) foods that are populated and kept up-to-date so they're always ready when the user presents this
    @Published var recents: [Food] = []
    @Published var allMyFoods: [Food] = []

    //MARK: - Legacy
    
    @Published var results = [FoodSearchResult]()
    
    @Published var isLoadingPage = false
    var currentPage = 1
    var canLoadMorePages = true
    
    public init() {
    }
}
