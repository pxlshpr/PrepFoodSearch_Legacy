import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar
import ActivityIndicatorView
import Camera
import SwiftSugar
import PrepViews
//import PrepFoodForm
//import FoodLabelExtractor

public struct FoodSearch<Content: View>: View {
    
    @Namespace var namespace
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss

//    @ObservedObject var foodFormFields: FoodForm.Fields
//    @ObservedObject var foodFormSources: FoodForm.Sources
//    @ObservedObject var foodFormExtractor: Extractor
    
    @State var wasInBackground: Bool = false
    @State var focusFakeKeyboardWhenVisible = false
    @FocusState var fakeKeyboardFocused: Bool

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
    
    @State var showingAddFood = false

    @State var showingAddHeroButton: Bool
    
    @Binding var searchIsFocused: Bool

    let didTapClose: (() -> ())?
    let didTapFood: (Food) -> ()
    let didTapMacrosIndicatorForFood: (Food) -> ()
    let didTapAddFood: () -> ()
    
    let focusOnAppear: Bool
    let isRootInNavigationStack: Bool
    
//    let foodForm: Content
    let foodForm: () -> Content

    public init(
        @ViewBuilder foodForm: @escaping () -> Content,
//        fields: FoodForm.Fields, sources: FoodForm.Sources, extractor: Extractor,
        dataProvider: SearchDataProvider,
        isRootInNavigationStack: Bool,
        shouldDelayContents: Bool = true,
        focusOnAppear: Bool = false,
        searchIsFocused: Binding<Bool>,
        didTapAddFood: @escaping () -> (),
        didTapClose: (() -> ())? = nil,
        didTapFood: @escaping ((Food) -> ()),
        didTapMacrosIndicatorForFood: @escaping ((Food) -> ())
    ) {
        self.foodForm = foodForm
        self.isRootInNavigationStack = isRootInNavigationStack
        
//        self.foodFormFields = fields
//        self.foodFormSources = sources
//        self.foodFormExtractor = extractor
        
        let searchViewModel = SearchViewModel(recents: dataProvider.recentFoods)
        _searchViewModel = StateObject(wrappedValue: searchViewModel)
        
        let searchManager = SearchManager(
            searchViewModel: searchViewModel,
            dataProvider: dataProvider
        )
        _searchManager = StateObject(wrappedValue: searchManager)
        
        self.focusOnAppear = focusOnAppear
        
        //TODO: Replace this with a single action handler and an (associated) enum
        self.didTapAddFood = didTapAddFood
        self.didTapClose = didTapClose
        self.didTapFood = didTapFood
        self.didTapMacrosIndicatorForFood = didTapMacrosIndicatorForFood
        
        _showingAddHeroButton = State(initialValue: focusOnAppear)
        _hasAppeared = State(initialValue: shouldDelayContents ? false : true)
        
        _searchIsFocused = searchIsFocused
    }
    
    var background: some View {
        FormBackground()
            .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    public var body: some View {
        content
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    hasAppeared = true
                }
            }
        }
        .transition(.opacity)
//        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { trailingContent }
        .toolbar { principalContent }
        .toolbar { leadingContent }
        .onChange(of: searchViewModel.searchText, perform: searchTextChanged)
        .onChange(of: scenePhase, perform: scenePhaseChanged)
        .onChange(of: searchIsFocused, perform: searchIsFocusedChanged)
//        .onChange(of: showingAddFood, perform: showingAddFoodChanged)
        .fullScreenCover(isPresented: $showingAddFood) { foodFormSheet }
    }
    
    var foodFormSheet: some View {
        foodForm()
//        FoodForm(fields: foodFormFields, sources: foodFormSources, extractor: foodFormExtractor) { formOutput in
//            didAddFood(formOutput)
//        }
//        .onDisappear {
//            foodFormExtractor.cancelAllTasks()
//        }
    }

    @State var initialSearchIsFocusedChangeIgnored: Bool = false
    
    func hideHeroAddButton() {
        withAnimation {
            if showingAddHeroButton {
                showingAddHeroButton = false
            }
        }
    }
    
    func searchIsFocusedChanged(_ newValue: Bool) {
        if initialSearchIsFocusedChangeIgnored {
            hideHeroAddButton()
        } else {
            initialSearchIsFocusedChangeIgnored = true
        }
    }

    func scenePhaseChanged(to newPhase: ScenePhase) {
        switch newPhase {
        case .background:
            wasInBackground = true
        case .active:
            if wasInBackground, showingAddFood {
                focusFakeKeyboardWhenVisible = true
                wasInBackground = false
            }
        default:
            break
        }
    }
    
    var fakeTextField: some View {
        TextField("", text: .constant(""))
            .focused($fakeKeyboardFocused)
            .opacity(0)
    }

    func showingAddFoodChanged(_ showing: Bool) {
        guard !showing else { return }
        guard focusFakeKeyboardWhenVisible else { return }
        focusFakeKeyboardWhenVisible = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            fakeKeyboardFocused = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                fakeKeyboardFocused = false
            }
            /// failsafe in case it wasn't unfocused
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                fakeKeyboardFocused = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                fakeKeyboardFocused = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                fakeKeyboardFocused = false
            }
        }
    }
    
    @ViewBuilder
    var content: some View {
        if !hasAppeared {
            background
        } else {
            ZStack {
                searchableView
                addHeroLayer
                fakeTextField
            }
            .sheet(isPresented: $showingBarcodeScanner) { barcodeScanner }
            .sheet(isPresented: $showingFilters) { filtersSheet }
            .onChange(of: isComparing, perform: isComparingChanged)
            .background(background)
        }
    }
    
    var addHeroLayer: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                if showingAddHeroButton {
                    addHeroButton
//                    addHeroMenu
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 20)
        }
//        .ignoresSafeArea(.keyboard)
        .padding(.bottom, 65 + 10)
//        .edgesIgnoringSafeArea(.all)
    }
    
    var addHeroButton: some View {
        Button {
            /// Resets the `FoodForm.Fields` and `FoodForm.Sources` fields
            didTapAddFood()
            
            /// Actually shows the `View` for the `FoodForm` that we were passed in
            showingAddFood = true
            
            /// Resigns focus on search and hides the hero button
            searchIsFocused = false
            showingAddHeroButton = false
            
        } label: {
            Label("Food", systemImage: FoodType.food.systemImage)
        }
    }
    
    var addHeroMenu: some View {
        Menu {
            addHeroButton
            Button {
                didTapAddFood()
            } label: {
                Label("Recipe", systemImage: FoodType.recipe.systemImage)
            }
            Button {
                didTapAddFood()
            } label: {
                Label("Plate", systemImage: FoodType.plate.systemImage)
            }
        } label: {
            Image(systemName:  "plus")
                .font(.system(size: 25))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(
                    ZStack {
                        Circle()
                            .foregroundStyle(Color.accentColor.gradient)
                    }
                    .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                )
        }
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded {
            Haptics.selectionFeedback()
        })
    }
    var searchableView: some View {
        var content: some View {
//            ZStack {
                list
//                addHeroLayer
//            }
        }
        
        return SearchableView(
            searchText: $searchViewModel.searchText,
            promptSuffix: "Foods",
            focused: $searchIsFocused,
            focusOnAppear: focusOnAppear,
            isHidden: $isComparing,
            showKeyboardDismiss: true,
//            showDismiss: false,
//            didTapDismiss: didTapClose,
            didSubmit: didSubmit,
            buttonViews: {
                EmptyView()
                scanButton
            },
            content: {
                content
            })
    }
    
    func searchTextChanged(to searchText: String) {
        hideHeroAddButton()
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
//            createSection
//            Section(header: Text("")) {
//                EmptyView()
//            }
        }
    }
    
    var createSection: some View {
        return Group {
            Section {
                Button {
                    searchIsFocused = false
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showingAddFood = true
//                    }
//                    didTapAddFood()
                } label: {
                    Label("Create New Food", systemImage: "plus")
                }
//                Button {
//
//                } label: {
//                    Label("Scan a Food Label", systemImage: "text.viewfinder")
//                }
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
                hideHeroAddButton()
                didTapFood(food)
//                searchIsFocused = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    searchIsFocused = false
//                    didTapFood(food)
                }
            } else {
                hideHeroAddButton()
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
        }
    }
    
    @ViewBuilder
    func header(for scope: SearchScope) -> some View {
        switch scope {
        case .backend:
            Text("My Foods")
        case .verified, .verifiedLocal:
            verifiedHeader
        case .datasets:
            publicDatasetsHeader
        }
    }
    
    @ViewBuilder
    var searchPromptSection: some View {
        if shouldShowSearchPrompt {
//            Section {
            Button {
                didSubmit()
            } label: {
                Text("Tap search to find foods matching '\(searchViewModel.searchText)' in our databases.")
                        .foregroundColor(.secondary)
            }
            .listRowBackground(FormCellBackground())
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
                                searchManager.loadMoreResults(for: scope)
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

struct FoodSearchConstants {
    
    /// ** Hardcoded and repeated **
    static let largeDeviceWidthCutoff: CGFloat = 850.0
    static let keyboardHeight: CGFloat = UIScreen.main.bounds.height < largeDeviceWidthCutoff
    ? 291
    : 301
}
