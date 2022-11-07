import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar
import ActivityIndicatorView
import Camera
import SwiftSugar
import PrepViews

public struct FoodSearch: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var searchViewModel: SearchViewModel
    @StateObject var searchManager: SearchManager

    @State var showingBarcodeScanner = false
    @State var searchIsFocused = false
    @State var showingFilters = false
    
    @State var searchingVerified = false
    @State var searchingDatasets = false
    
    @State var isComparing = false
    
    @State var hasAppeared = false
    
    public init(dataProvider: SearchDataProvider) {
        
        let searchViewModel = SearchViewModel(recents: dataProvider.recentFoods)
        _searchViewModel = StateObject(wrappedValue: searchViewModel)
        
        let searchManager = SearchManager(
            searchViewModel: searchViewModel,
            dataProvider: dataProvider
        )
        _searchManager = StateObject(wrappedValue: searchManager)
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
        .onChange(of: searchViewModel.searchText, perform: searchTextChanged)
    }
    
    func searchTextChanged(to searchText: String) {
        Task {
            await searchManager.performBackendSearch()
        }
    }

    @ViewBuilder
    var list: some View {
        if searchViewModel.searchText.isEmpty {
            recentsList
        } else {
            resultsList
        }
    }

    var resultsList: some View {
        List {
            resultsContents
        }
//        .safeAreaInset(edge: .bottom) {
//            Spacer().frame(height: 0)
//        }
        .listStyle(.sidebar)
    }
    
    var recentsList: some View {
        List {
            emptySearchContents
        }
//        .safeAreaInset(edge: .bottom) {
//            Spacer().frame(height: 90)
//        }
        .listStyle(.insetGrouped)
    }
    
    @ViewBuilder
    var emptySearchContents: some View {
        Group {
            if !searchViewModel.recents.isEmpty {
                recentsSection
            } else if !searchViewModel.allMyFoods.isEmpty {
                allMyFoodsSection
            }
            createSection
        }
    }
    
    var createSection: some View {
        var createHeader: some View {
            Text("Create a Food")
//            Label("Create a Food", systemImage: "plus")
        }
        return Group {
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
            ForEach(searchViewModel.recents, id: \.self) { food in
                FoodCell(food: food, isSelectable: $isComparing) { isSelected in
                    print("isSelected for: \(food.name) changed to \(isSelected)")
                }
            }
        }
    }
    
    var resultsContents: some View {
        Group {
            foodsSection(for: .backend)
            foodsSection(for: .verified)
            foodsSection(for: .datasets)
        }
    }
    
    @ViewBuilder
    func header(for scope: SearchScope) -> some View {
        switch scope {
        case .backend:
            Text("My Foods")
        case .verified:
            verifiedHeader
        case .datasets:
            publicDatasetsHeader
        }
    }
    
    func foodsSection(for scope: SearchScope) -> some View {
        let results = searchViewModel.results(for: scope)
        return Group {
            if let foods = results.foods {
                Section(header: header(for: scope)) {
                    if foods.isEmpty {
                        if results.isLoading {
                            loadingCell
                        } else {
                            noResultsCell
                        }
                    } else {
                        ForEach(foods, id: \.self) {
                            FoodCell(food: $0, isSelectable: $isComparing) { isSelected in
                                
                            }
                        }
                        if results.isLoading {
                            loadingCell
                        } else {
                            loadMoreCell {
                                searchViewModel.loadMoreResults(for: scope)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var noResultsCell: some View {
        Text("No results")
            .foregroundColor(Color(.tertiaryLabel))
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
