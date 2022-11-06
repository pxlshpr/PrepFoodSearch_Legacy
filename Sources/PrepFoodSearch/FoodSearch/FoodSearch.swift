import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar
import ActivityIndicatorView
import Camera
import SwiftSugar

public struct FoodSearch: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var searchManager: SearchManager
    @State var showingBarcodeScanner = false
    @State var searchIsFocused = false
    @State var showingFilters = false
    
    @State var searchingVerified = false
    @State var searchingDatasets = false
    
    @State var isComparing = false
    
    @State var hasAppeared = false
    
    public init(searchManager: SearchManager) {
        self.searchManager = searchManager
    }
    
    @ViewBuilder
    public var body: some View {
        ZStack {
            if !hasAppeared {
                Color(.systemGroupedBackground)
            } else {
                searchableView
                    .sheet(isPresented: $showingBarcodeScanner) { barcodeScanner }
                    .sheet(isPresented: $showingFilters) { filtersSheet }
                    .onChange(of: isComparing, perform: isComparingChanged)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    hasAppeared = true
                }
            }
        }
        .transition(.opacity)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { trailingContent }
        .toolbar { principalContent }
        .toolbar { leadingToolbar }
    }
    
    @ViewBuilder
    var list: some View {
        if searchManager.searchText.isEmpty {
            recentsList
        } else {
            resultsList
        }
    }
    
    var recentsList: some View {
        List {
            emptySearchContents
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: 66)
        }
        .listStyle(.insetGrouped)
    }
    
    @ViewBuilder
    var emptySearchContents: some View {
        if !searchManager.recents.isEmpty {
            recentsSection
        } else if !searchManager.allMyFoods.isEmpty {
            allMyFoodsSection
        } else {
            noDeviceFoodsSection
        }
    }
    
    var noDeviceFoodsSection: some View {
        noDeviceFoodsCell
    }

    var noDeviceFoodsCell: some View {
        var createHeader: some View {
            Text("Create a Food")
//            Label("Create a Food", systemImage: "plus")
        }
        return Group {
//            Section {
//                Text("Search over 1 million foods in our database.")
//                .foregroundColor(.secondary)
//                .listRowSeparator(.hidden)
//            }
            Section(header: createHeader) {
                Button {
                    
                } label: {
                    Label("Start with an Empty Food", systemImage: "square.and.pencil")
                }
                Button {
                    
                } label: {
                    Label("Scan a Food Label or Screenshot", systemImage: "text.viewfinder")
                }
                Button {
                    
                } label: {
                    Label("Import a Food from MyFitnessPal", systemImage: "square.and.arrow.down")
                }
            }
        }
    }
    
    var resultsList: some View {
        List {
            resultsContents
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: 66)
        }
        .listStyle(.sidebar)
    }
    
    var allMyFoodsSection: some View {
        var header: some View {
            HStack {
                Text("My Foods")
            }
        }
        
        return Section(header: header) {
            Text("All my foods go here")
        }
    }
    
    var recentsSection: some View {
        var header: some View {
            HStack {
                Image(systemName: "clock")
                Text("Recents")
            }
        }
        
        return Section(header: header) {
            Text("Recents")
        }
    }
    
    var resultsContents: some View {
        Group {
            myFoodsSection
            verifiedFoodsSection
            datasetFoodsSection
        }
    }
    
    var verifiedFoodsSection: some View {
        Section(header: verifiedHeader) {
            if searchManager.verifiedResults.foods.isEmpty {
                if searchManager.verifiedResults.isLoading {
                    loadingCell
                } else {
                    Text("No results")
                }
            } else {
                ForEach(searchManager.verifiedResults.foods, id: \.self) {
                    FoodCell(food: $0, isComparing: $isComparing)
                }
                if searchManager.verifiedResults.isLoading {
                    loadingCell
                } else {
                    loadMoreCell {
                        searchManager.verifiedResults.isLoading = true
                    }
                }
            }
        }
    }
    
    var datasetFoodsSection: some View {
        Section(header: publicDatasetsHeader) {
            if searchManager.datasetResults.foods.isEmpty {
                if searchManager.datasetResults.isLoading {
                    loadingCell
                } else {
                    Text("No results")
                }
            } else {
                ForEach(searchManager.datasetResults.foods, id: \.self) {
                    FoodCell(food: $0, isComparing: $isComparing)
                }
                if searchManager.datasetResults.isLoading {
                    loadingCell
                } else {
                    loadMoreCell {
                        searchManager.datasetResults.isLoading = true
                    }
                }
            }
        }
    }
    
    var myFoodsSection: some View {
        Section("My Foods") {
            if searchManager.myFoodResults.foods.isEmpty {
                if searchManager.myFoodResults.isLoading {
                    loadingCell
                } else {
                    Text("No results")
                }
            } else {
                ForEach(searchManager.myFoodResults.foods, id: \.self) {
                    FoodCell(food: $0, isComparing: $isComparing)
                }
                if searchManager.myFoodResults.isLoading {
                    loadingCell
                } else {
                    loadMoreCell {
                        searchManager.myFoodResults.isLoading = true
                    }
                }
            }
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

extension FoodCell {
    init(food: Food, isComparing: Binding<Bool>) {
        self.init(
            isComparing: isComparing,
            emoji: food.emoji,
            name: food.name,
            detail: food.detail,
            brand: food.brand,
            carb: food.info.nutrients.carb,
            fat: food.info.nutrients.fat,
            protein: food.info.nutrients.protein
        )
    }
}

enum SearchError: Error {
    
}

enum SearchStep {
    case backend
    case verified
    case datasets
}

public struct FoodSearchPreview: View {
    
    @StateObject var searchManager = SearchManager()
    
    public var body: some View {
        NavigationView {
            FoodSearch(searchManager: searchManager)
                .onChange(of: searchManager.searchText, perform: searchTextChanged)
        }
    }
    
    func searchTextChanged(to searchText: String) {
        guard !searchText.isEmpty else { return }
        
        Task {
            return try await withThrowingTaskGroup(of: Result<SearchStep, SearchError>.self) { group in
                
                group.addTask {
                    try await searchBackend(with: searchText)
                    return .success(.backend)
                }

                group.addTask {
                    try await searchVerifiedFoods(with: searchText)
                    return .success(.verified)
                }

                group.addTask {
                    try await searchDatasetFoods(with: searchText)
                    return .success(.datasets)
                }

                let start = CFAbsoluteTimeGetCurrent()

                for try await result in group {
                    switch result {
                    case .success(let step):
                        print("💾 Save Step: \(step) completed in \(CFAbsoluteTimeGetCurrent()-start)s")
                    case .failure(let error):
                        throw error
                    }
                }

                print("✅ Search completed in \(CFAbsoluteTimeGetCurrent()-start)s")
            }
        }
    }
    
    func searchBackend(with searchText: String) async throws {
        searchManager.myFoodResults.isLoading = true
        Task {
            let foods = try await getMyFoodsFromBackend(searchText: searchText)
            await MainActor.run {
                withAnimation {
                    searchManager.myFoodResults.foods = foods
                    searchManager.myFoodResults.isLoading = false
                }
            }
        }
    }

    func searchVerifiedFoods(with searchText: String) async throws {
        searchManager.verifiedResults.isLoading = true
        Task {
            let foods = try await getVerifiedFoodsFromBackend(searchText: searchText)
            await MainActor.run {
                withAnimation {
                    searchManager.verifiedResults.foods = foods
                    searchManager.verifiedResults.isLoading = false
                }
            }
        }
    }

    func searchDatasetFoods(with searchText: String) async throws {
        searchManager.datasetResults.isLoading = true
        Task {
            let foods = try await getDatasetFoodsFromBackend(searchText: searchText)
            await MainActor.run {
                withAnimation {
                    searchManager.datasetResults.foods = foods
                    searchManager.datasetResults.isLoading = false
                }
            }
        }
    }

    func getMyFoodsFromBackend(searchText: String) async throws -> [Food] {
        try await sleepTask(Double.random(in: 0.2...2.5))
        return [
            Food(mockName: "Cheese", emoji: "🧀"),
            Food(mockName: "KFC Leg", emoji: "🍗"),
            Food(mockName: "Carrot", emoji: "🥕"),
            Food(mockName: "Beans", emoji: "🫘"),
            Food(mockName: "Brinjal", emoji: "🍆"),
        ]
    }

    func getVerifiedFoodsFromBackend(searchText: String) async throws -> [Food] {
        try await sleepTask(Double.random(in: 0.2...2.5))
        return [
            Food(mockName: "Cheese", emoji: "🧀"),
            Food(mockName: "KFC Leg", emoji: "🍗"),
            Food(mockName: "Carrot", emoji: "🥕"),
            Food(mockName: "Beans", emoji: "🫘"),
            Food(mockName: "Brinjal", emoji: "🍆"),
        ]
    }

    func getDatasetFoodsFromBackend(searchText: String) async throws -> [Food] {
        try await sleepTask(Double.random(in: 0.2...2.5))
        return [
            Food(mockName: "Cheese", emoji: "🧀"),
            Food(mockName: "KFC Leg", emoji: "🍗"),
            Food(mockName: "Carrot", emoji: "🥕"),
            Food(mockName: "Beans", emoji: "🫘"),
            Food(mockName: "Brinjal", emoji: "🍆"),
        ]
    }

    public init() { }
}

struct FoodSearch_Previews: PreviewProvider {
    static var previews: some View {
        FoodSearchPreview()
    }
}

