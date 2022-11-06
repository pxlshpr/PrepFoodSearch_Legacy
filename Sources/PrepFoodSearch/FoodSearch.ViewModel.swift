import SwiftUI
import PrepNetworkController
import PrepDataTypes
import SwiftHaptics
import SwiftSugar
import VisionSugar

enum ResultGroupType {
    case myFoods
    case verified
    case datasets
}

struct ResultGroup {
    let type: ResultGroupType
    let results: [FoodSearchResult] = []
}

extension FoodSearch {
    
    class ViewModel: ObservableObject {
        
//        let networkController = NetworkController.server
        
        @Published var searchText: String = "Banana"
        
        @Published var results = [FoodSearchResult]()

        @Published var resultGroups: [ResultGroup] = []
        
        @Published var isLoadingPage = false
        private var currentPage = 1
        private var canLoadMorePages = true
        
//        var foods: [PrepFood] = []
        
        init() {
        }
    }
}

extension FoodSearch.ViewModel{
    
    func search() {
        results = []
//        foods = []
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
        
        let thresholdIndex = results.index(results.endIndex, offsetBy: -10)
        if results.firstIndex(where: { $0.id == result.id }) == thresholdIndex {
            loadMoreContent()
        }
    }
    
    private func loadMoreContent() {
        guard !isLoadingPage && canLoadMorePages else {
            print("✨ Not loading more — isLoadingPage: \(isLoadingPage), canLoadMorePages: \(canLoadMorePages)")
            return
        }
        
        isLoadingPage = true
        
        Task {
            print("✨ Sending request for page: \(currentPage)")
//            let params = ServerFoodSearchParams(string: searchText, page: currentPage, per: 25)
//            let page = try await networkController.searchFoods(params: params)
//            await MainActor.run {
//                self.didReceive(page)
//            }
        }
    }
    
//    func didReceive(_ page: FoodsPage) {
//        if currentPage == 1 {
//            Haptics.successFeedback()
//        } else {
//            Haptics.feedback(style: .soft)
//        }
//
//        canLoadMorePages = page.hasMorePages
//        isLoadingPage = false
//
//        add(page.items)
//        currentPage += 1
//    }
    
    func add(_ newResults: [FoodSearchResult]) {
        /// Filter out the results that definitely don't exist in our current array before appending it (to avoid duplicates)
        let trulyNewResults = newResults.filter { newResult in
            !results.contains(where: { $0.id == newResult.id })
        }
        if currentPage == 1 {
            withAnimation {
                results.append(contentsOf: trulyNewResults)
            }
        } else {
            results.append(contentsOf: trulyNewResults)
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            self.getFoods(for: trulyNewResults)
//        }
    }
    
    func getFoods(for results: [FoodSearchResult]) {
        Task {
            do {
//                let newFoods = try await networkController.foods(for: results)
//                foods.append(contentsOf: newFoods)
            } catch {
                print("Error getting foods: \(error)")
            }
        }
    }
}

extension FoodSearch.ViewModel {
//    func search(for barcodes: [RecognizedBarcode]) async throws -> PrepFood {
//        let payloads = barcodes.map { $0.string }
//        return try await networkController.findFood(for: payloads)
//    }
}

import SwiftUI
import SwiftHaptics
import ActivityIndicatorView
import Camera
import PrepViews

extension FoodSearch {

    var resultsContents: some View {
        Group {
            ForEach(viewModel.results) { result in
                Button {
                    Haptics.feedback(style: .soft)
                    searchIsFocused = false
                } label: {
                    FoodCell(result: result)
                        .buttonStyle(.borderless)
                }
                .onAppear {
                    viewModel.loadMoreContentIfNeeded(currentResult: result)
                }
            }
            if viewModel.isLoadingPage {
                HStack {
                    Spacer()
                    ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                        .frame(width: 50, height: 50)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .listRowSeparator(.hidden)
//                ProgressView()
            }
        }
    }
    
    //MARK: Buttons
    var scanButton: some View {
        Button {
            searchIsFocused = false
            showingBarcodeScanner = true
        } label: {
            Image(systemName: "barcode.viewfinder")
                .imageScale(.large)
        }
    }
    
    var filterButton: some View {
        Button {
            showingFilters = true
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .imageScale(.large)
        }
    }
    
    //MARK: Sheets
    
    var filtersSheet: some View {
        FiltersSheet()
    }
    
    var barcodeScanner: some View {
        BarcodeScanner { barcodes in
//            Task {
//                let food = try await viewModel.search(for: barcodes)
//                await MainActor.run {
//                    self.foodToPresent = food
//                }
//            }
        }
    }
    
    var list_legacy: some View {
        List {
            resultsContents
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: 66)
        }
        .listStyle(.plain)
    }
    
    
    
    var list: some View {
        List {
            Section(header: myFoodsHeader) {
                FoodCell(emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
            }
            Section(header: verifiedHeader) {
                FoodCell(emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                Button {
                    
                } label: {
                    Text("Load More")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderless)
//                HStack {
//                    ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
//                        .frame(width: 20, height: 20)
//                        .foregroundColor(.secondary)
//                }
//                .frame(maxWidth: .infinity, alignment: .center)
            }
            Section(header: publicDatasetsHeader) {
                FoodCell(emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                Button {
                    
                } label: {
                    Text("Load More")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderless)
//                HStack {
//                    ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
//                        .frame(width: 20, height: 20)
//                        .foregroundColor(.secondary)
//                }
//                .frame(maxWidth: .infinity, alignment: .center)
            }
//            resultsContents
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: 66)
        }
        .listStyle(.sidebar)
    }
    
    var myFoodsHeader: some View {
        HStack {
//            Image(systemName: "person.fill")
//                .foregroundColor(.secondary)
            Text("My Foods")
        }
    }

    var verifiedHeader: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.green)
            Text("Verified Foods")
        }
    }

    var publicDatasetsHeader: some View {
        HStack {
            Image(systemName: "text.book.closed.fill")
                .foregroundColor(.secondary)
            Text("Public Datasets")
        }
    }

}


public struct FoodSearchPreview: View {
    public var body: some View {
        NavigationView {
            FoodSearch()
        }
    }
    
    public init() { }
}

struct FoodSearch_Previews: PreviewProvider {
    static var previews: some View {
        FoodSearchPreview()
    }
}
