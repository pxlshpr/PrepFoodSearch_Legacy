import SwiftUI
import PrepNetworkController
import PrepDataTypes
import SwiftHaptics
import SwiftSugar
import VisionSugar
import SwiftHaptics

public class SearchManager: ObservableObject {
    
    public static let shared = SearchManager()
    
    @Published var searchText: String = "Banana"
    
    @Published var results = [FoodSearchResult]()
    @Published var resultGroups: [ResultGroup] = []
    
    @Published var isLoadingPage = false
    var currentPage = 1
    var canLoadMorePages = true
    
    public init() {
    }
    
    enum ResultGroupType {
        case myFoods
        case verified
        case datasets
    }

    struct ResultGroup {
        let type: ResultGroupType
        let results: [FoodSearchResult] = []
    }
}
