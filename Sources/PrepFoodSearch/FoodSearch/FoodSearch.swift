import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar

public struct FoodSearch: View {
    
    @StateObject var viewModel = ViewModel()
    @State var showingBarcodeScanner = false
    @State var searchIsFocused = false
    @State var showingFilters = false
    
    public var body: some View {
        searchableView
            .navigationTitle("Search Foods")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingBarcodeScanner) { barcodeScanner }
            .sheet(isPresented: $showingFilters) { filtersSheet }
    }
    
    var searchableView: some View {
        SearchableView(
            searchText: $viewModel.searchText,
            prompt: "Search Foods",
            focused: $searchIsFocused,
            focusOnAppear: true,
            didSubmit: didSubmit,
            buttonViews: {
                filterButton
                scanButton
            },
            content: {
                list
            })
    }
}

