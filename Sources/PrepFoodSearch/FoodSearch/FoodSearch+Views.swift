import SwiftUI
import SwiftHaptics
import ActivityIndicatorView
import Camera

extension FoodSearch {

    var list: some View {
        List {
            resultsContents
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: 66)
        }
        .listStyle(.plain)
    }
    
    var resultsContents: some View {
        Group {
            ForEach(viewModel.results) { result in
                Button {
                    Haptics.feedback(style: .soft)
                    searchIsFocused = false
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
    
}
