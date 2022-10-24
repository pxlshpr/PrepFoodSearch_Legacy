import SwiftUI
import Camera
import ActivityIndicatorView
import PrepUnits
import SwiftHaptics

public struct FoodSearch: View {
    
    @StateObject var viewModel = FoodSearchViewModel()
    @State var showingBarcodeScanner = false
    @State var searchIsFocused = false
    
    @State var showingFilters = false
    
    public var body: some View {
        searchableView
            .sheet(isPresented: $showingBarcodeScanner) { barcodeScanner }
            .sheet(isPresented: $showingFilters) { filtersSheet }
    }
    
    var filtersSheet: some View {
        FiltersSheet()
    }
    
    var searchableView: some View {
        NavigationView {
            SearchableView(
                searchText: $viewModel.searchText,
                prompt: "Search Foods",
                focused: $searchIsFocused,
                didSubmit: didSubmit,
                buttonViews: {
                    filterButton
                    scanButton
                },
                content: {
                    list
        //            scrollView
                })
                .navigationTitle("Food Search")
                .navigationBarTitleDisplayMode(.inline)
        }

//        SearchableView(
//            searchText: $viewModel.searchText,
//            prompt: "Search Foods",
//            focused: $searchIsFocused,
//            didSubmit: didSubmit,
//            buttonViews: {
//                filterButton
//                scanButton
//            },
//            content: {
//                navigationView
//            })
        
    }
    
    func didSubmit() {
        viewModel.search()
    }
    
    var navigationView: some View {
        NavigationView {
            list
//            scrollView
                .navigationTitle("Food Search")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var list: some View {
        List {
            resultsContents
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: 66)
        }
        .listStyle(.plain)
    }
    
    var scrollView: some View {
        ScrollView {
            LazyVStack {
                resultsContents
            }
        }
    }
    
    var resultsContents: some View {
        Group {
            ForEach(viewModel.results) { result in
                NavigationLink {
                    FoodView(result)
                        .environmentObject(viewModel)
//                    Haptics.feedback(style: .soft)
//                    viewModel.present(result)
                } label: {
                    FoodSearchResultCell(searchResult: result)
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
    
    var barcodeScanner: some View {
        BarcodeScanner { barcodes, image in
            if let string = barcodes.first?.string {
                self.viewModel.searchText = string
            }
        }
    }
    
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
}

public struct FoodSearchPreview: View {
    public var body: some View {
        FoodSearch()
    }
    
    public init() { }
}

struct FoodSearch_Previews: PreviewProvider {
    static var previews: some View {
        FoodSearchPreview()
    }
}
