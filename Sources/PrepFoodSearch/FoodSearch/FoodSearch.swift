import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar

public struct FoodSearch: View {
    
    @StateObject var viewModel = ViewModel()
    @State var showingBarcodeScanner = false
    @State var searchIsFocused = false
    @State var showingFilters = false
    
    @State var searchingVerified = false
    @State var searchingDatasets = false
    
    public var body: some View {
        searchableView
//            .navigationTitle("Hello")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { principalContent }
            .sheet(isPresented: $showingBarcodeScanner) { barcodeScanner }
            .sheet(isPresented: $showingFilters) { filtersSheet }
    }
    
    @State var foodType: String = "Foods"
    var principalContent: some ToolbarContent {
        ToolbarItemGroup(placement: .principal) {
            HStack {
                Text("Search")
                    .font(.headline)
                Picker("", selection: $foodType) {
                    Text("Foods").tag("Foods")
                    Text("Recipes").tag("Recipes")
                    Text("Plates").tag("Plates")
                }
                .pickerStyle(.segmented)
            }
        }
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
