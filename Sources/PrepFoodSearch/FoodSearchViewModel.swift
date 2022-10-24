import SwiftUI
import PrepNetworkController
import PrepUnits
import SwiftHaptics
import SwiftSugar

class FoodSearchViewModel: ObservableObject {
    
    let networkController = NetworkController.server
    
    @Published var searchText: String = ""
    
    @Published var results = [FoodSearchResult]()
    @Published var isLoadingPage = false
    private var currentPage = 1
    private var canLoadMorePages = true
    
    var foods: [PrepFood] = []
    
    @Published var foodIdBeingPresented: UUID? = nil
    @Published var foodBeingPresented: PrepFood? = nil
    @Published var showingFood = false

    init() {
    }
    
    func present(_ result: FoodSearchResult) {
        /// See if we already have the food—otherwise, start a task to retrieve it
        if let food = foods.first(where: { $0.id == result.id }) {
            foodBeingPresented = food
        } else {
            //TODO: Get the food here
        }
        foodIdBeingPresented = result.id
        showingFood = true
    }
    
    func search() {
        results = []
        foods = []
        currentPage = 1
        canLoadMorePages = true
        isLoadingPage = false
        loadMoreContent()
    }
    
    func loadMoreContentIfNeeded(currentResult result: FoodSearchResult?) {
        guard let result else {
            loadMoreContent()
            return
        }
        
        let thresholdIndex = results.index(results.endIndex, offsetBy: -5)
        if results.firstIndex(where: { $0.id == result.id }) == thresholdIndex {
            loadMoreContent()
        }
    }
    
    private func loadMoreContent() {
        guard !isLoadingPage && canLoadMorePages else {
            return
        }
        
        isLoadingPage = true
        
        Task {
            let params = ServerFoodSearchParams(string: searchText, page: currentPage, per: 25)
            let page = try await networkController.searchFoods(params: params)
            await MainActor.run {
                self.didReceive(page)
            }
        }
    }
    
    func didReceive(_ page: FoodsPage) {
        if currentPage == 1 {
            Haptics.successFeedback()
        } else {
            Haptics.feedback(style: .soft)
        }
        
        canLoadMorePages = page.hasMorePages
        isLoadingPage = false
        
        add(page.items)
        currentPage += 1
    }
    
    func add(_ newResults: [FoodSearchResult]) {
        if currentPage == 1 {
            withAnimation {
                results.append(contentsOf: newResults)
            }
        } else {
            results.append(contentsOf: newResults)
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.getFoods(for: newResults)
//        }
    }
    
    func getFoods(for results: [FoodSearchResult]) {
        Task {
            do {
                let newFoods = try await networkController.foods(for: results)
                foods.append(contentsOf: newFoods)
                
                if let foodIdBeingPresented,
                   let food = newFoods.first(where: { $0.id == foodIdBeingPresented })
                {
                    await MainActor.run {
                        withAnimation {
                            foodBeingPresented = food
                        }
                    }
                }
            } catch {
                print("Error getting foods: \(error)")
            }
        }
    }
}

