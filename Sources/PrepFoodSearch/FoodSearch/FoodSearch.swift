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
    @State var showingFilters = false
    
    @State var searchingVerified = false
    @State var searchingDatasets = false
    
    @State var isComparing = false
    
    @State var hasAppeared: Bool
    @State var shouldShowRecents: Bool = true
    @State var shouldShowSearchPrompt: Bool = false

    @Binding var searchIsFocused: Bool

    let didTapClose: (() -> ())?
    let didTapFood: (Food) -> ()
    let didTapMacrosIndicatorForFood: (Food) -> ()
    
    let focusOnAppear: Bool
    
    public init(
        dataProvider: SearchDataProvider,
        shouldDelayContents: Bool = true,
        focusOnAppear: Bool = false,
        searchIsFocused: Binding<Bool>,
        didTapClose: (() -> ())? = nil,
        didTapFood: @escaping ((Food) -> ()),
        didTapMacrosIndicatorForFood: @escaping ((Food) -> ())
    ) {
        
        let searchViewModel = SearchViewModel(recents: dataProvider.recentFoods)
        _searchViewModel = StateObject(wrappedValue: searchViewModel)
        
        let searchManager = SearchManager(
            searchViewModel: searchViewModel,
            dataProvider: dataProvider
        )
        _searchManager = StateObject(wrappedValue: searchManager)
        
        self.focusOnAppear = focusOnAppear
        
        //TODO: Replace this with a single action handler and an (associated) enum
        self.didTapClose = didTapClose
        self.didTapFood = didTapFood
        self.didTapMacrosIndicatorForFood = didTapMacrosIndicatorForFood
        
        _hasAppeared = State(initialValue: shouldDelayContents ? false : true)
        
        _searchIsFocused = searchIsFocused
    }
    
    var background: some View {
        FormBackground()
            .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    public var body: some View {
        ZStack {
            if !hasAppeared {
                background
            } else {
                searchableView
                    .sheet(isPresented: $showingBarcodeScanner) { barcodeScanner }
                    .sheet(isPresented: $showingFilters) { filtersSheet }
                    .onChange(of: isComparing, perform: isComparingChanged)
                    .background(background)
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
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { trailingContent }
        .toolbar { principalContent }
        .toolbar { leadingToolbar }
        .onChange(of: searchViewModel.searchText, perform: searchTextChanged)
    }
    
    func searchTextChanged(to searchText: String) {
        withAnimation {
            shouldShowRecents = searchText.isEmpty
            shouldShowSearchPrompt = searchViewModel.hasNotSubmittedSearchYet && searchText.count >= 3
        }
        Task {
            await searchManager.performBackendSearch()
        }
    }

    @ViewBuilder
    var list: some View {
        if shouldShowRecents {
            recentsList
        } else {
            resultsList
        }
    }

    var resultsList: some View {
        List {
            resultsContents
        }
        .scrollContentBackground(.hidden)
        .listStyle(.sidebar)
    }
    
    var recentsList: some View {
        List {
            emptySearchContents
        }
        .scrollContentBackground(.hidden)
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
            Spacer().frame(height: 37 + 5)
        }
    }
    
    var createSection: some View {
        var createHeader: some View {
            Text("Create a Food")
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
            .listRowBackground(FormCellBackground())
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
                foodButton(for: food)
            }
        }
        .listRowBackground(FormCellBackground())
    }
    
    func foodButton(for food: Food) -> some View {
        Button {
            /// This is crucial to avoid having the search elements floating on top when we come back this view.
            /// This has something to do with triggering the navigation push from a list element.
            if searchIsFocused {
                searchIsFocused = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    didTapFood(food)
                }
            } else {
                didTapFood(food)
            }
        } label: {
            FoodCell(
                food: food,
                isSelectable: $isComparing,
                didTapMacrosIndicator: {
                    didTapMacrosIndicatorForFood(food)
                },
                didToggleSelection: { _ in
                }
            )
        }
    }
    
    var resultsContents: some View {
        Group {
            foodsSection(for: .backend)
            foodsSection(for: .verified)
//            foodsSection(for: .datasets)
            searchPromptSection
            Spacer().frame(height: 37 + 5)
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
    
    @ViewBuilder
    var searchPromptSection: some View {
        if shouldShowSearchPrompt {
//            Section {
            Text("Tap search to find foods matching '\(searchViewModel.searchText)' in our databases.")
                    .foregroundColor(.secondary)
//            }
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
                            foodButton(for: $0)
                        }
                        if results.isLoading {
                            loadingCell
                        } else if results.canLoadMorePages {
                            loadMoreCell {
                                searchViewModel.loadMoreResults(for: scope)
                            }
                        }
                    }
                }
                .listRowBackground(FormCellBackground())
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
//                .foregroundColor(.green)
                .foregroundColor(.accentColor)
                .imageScale(.large)
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
