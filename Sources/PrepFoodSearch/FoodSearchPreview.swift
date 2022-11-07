import SwiftUI
import PrepDataTypes
import SwiftSugar

public struct FoodSearchPreview: View {
    
    @StateObject var searchViewModel: SearchViewModel
    @StateObject var searchManager: SearchManager
    
    public init() {
        let foods = [
            Food(mockName: "Cheese", emoji: "🧀"),
            Food(mockName: "KFC Leg", emoji: "🍗"),
            Food(mockName: "Carrot", emoji: "🥕"),
            Food(mockName: "Beans", emoji: "🫘"),
            Food(mockName: "Brinjal", emoji: "🍆"),
        ]
        
        let searchViewModel = SearchViewModel(recents: foods)
        _searchViewModel = StateObject(wrappedValue: searchViewModel)
        
        let mockDataProvider = MockDataProvider()
        let searchManager = SearchManager(
            searchViewModel: searchViewModel,
            dataProvider: mockDataProvider
        )
        _searchManager = StateObject(wrappedValue: searchManager)
    }

    public var body: some View {
        NavigationView {
            FoodSearch(
                searchViewModel: searchViewModel,
                searchManager: searchManager
            )
        }
    }
    
}

class MockDataProvider: SearchDataProvider {
    func getFoods(scope: SearchScope, searchText: String, page: Int = 1) async throws -> [Food] {
        try await sleepTask(Double.random(in: 2...5))
        return [
            Food(mockName: "Cheese", emoji: "🧀"),
            Food(mockName: "KFC Leg", emoji: "🍗"),
            Food(mockName: "Carrot", emoji: "🥕"),
            Food(mockName: "Beans", emoji: "🫘"),
            Food(mockName: "Brinjal", emoji: "🍆"),
        ]
    }
}
