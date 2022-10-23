import SwiftUI
import PrepNetworkController
import PrepUnits
import SwiftHaptics
import SwiftSugar

class FoodSearchViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    
    @Published var results = [FoodSearchResult]()
    @Published var isLoadingPage = false
    private var currentPage = 1
    private var canLoadMorePages = true
    
    init() {
    }
    
    func search() {
        results = []
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
            print("Getting page: \(currentPage)")
            let page = try await NetworkController.server.searchFoods(params: params)
//            try await sleepTask(2)
            await MainActor.run {
                if currentPage == 1 {
                    Haptics.successFeedback()
                } else {
                    Haptics.feedback(style: .soft)
                }
                self.canLoadMorePages = page.hasMorePages
                self.isLoadingPage = false
                if currentPage == 1 {
                    withAnimation {
                        self.results.append(contentsOf: page.items)
                    }
                } else {
                    self.results.append(contentsOf: page.items)
                }
                self.currentPage += 1
            }
        }
    }
}
