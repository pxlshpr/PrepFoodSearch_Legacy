import SwiftUI
import PrepDataTypes
import SwiftSugar

public struct FoodSearchPreview: View {
    
    public init() { }

    public var body: some View {
        NavigationView {
            FoodSearch(dataProvider: MockDataProvider())
        }
    }
    
}

class MockDataProvider: SearchDataProvider {
    var recentFoods: [Food] {
        mockFoodsArray
    }
    
    func getFoods(scope: SearchScope, searchText: String, page: Int = 1) async throws -> [Food] {
        try await sleepTask(Double.random(in: 2...5))
        return mockFoodsArray
    }
    
    var mockFoodsArray: [Food] {
        [
            Food(mockName: "Cheese", emoji: "🧀"),
            Food(mockName: "KFC Leg", emoji: "🍗"),
            Food(mockName: "Carrot", emoji: "🥕"),
            Food(mockName: "Beans", emoji: "🫘"),
            Food(mockName: "Brinjal", emoji: "🍆"),
        ]
    }
}
