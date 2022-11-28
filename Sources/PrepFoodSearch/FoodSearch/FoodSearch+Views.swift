import SwiftUI
import SwiftHaptics
import ActivityIndicatorView
import Camera
import PrepDataTypes
import SwiftUISugar

extension FoodSearch {
    
    //MARK: - Cells
   
    var loadingCell: some View {
        HStack {
            ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                .frame(width: 27, height: 27)
                .foregroundColor(.secondary)
                .offset(y: -2)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    func loadMoreCell(_ action: @escaping (() -> ())) -> some View {
        Button {
            Haptics.feedback(style: .rigid)
            action()
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 30))
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.accentColor)
        }
//        .buttonStyle(.borderless)
    }
    
    //MARK: - Buttons
    var scanButton: some View {
        Button {
            searchIsFocused = false
            showingBarcodeScanner = true
        } label: {
            Image(systemName: "barcode.viewfinder")
//            Image(systemName: "viewfinder.circle.fill")
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
            if let barcode = barcodes.first {
                searchViewModel.searchText = barcode.string
            }
        }
    }
    
    //MARK: - Toolbars
    
    var leadingToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            compareButton
        }
    }

    var principalContent: some ToolbarContent {
        ToolbarItemGroup(placement: .principal) {
            Group {
                if isComparing {
                    Text(title)
                        .font(.headline)
                } else {
                    Picker("", selection: $searchViewModel.foodType) {
                        ForEach(FoodType.allCases, id: \.self) {
                            Label("\($0.description)s", systemImage: $0.systemImage).tag($0)
                                .labelStyle(.titleAndIcon)
                        }
                    }
                    .pickerStyle(.menu)
                    .fixedSize(horizontal: true, vertical: false)
                    .contentShape(Rectangle())
                    .simultaneousGesture(TapGesture().onEnded {
                        Haptics.feedback(style: .soft)
                    })
                }
            }
        }
    }
    
    var trailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            closeButton
        }
    }
    
    var closeButton: some View {
        Button {
            tappedClose()
        } label: {
            closeButtonLabel
        }
    }
    
    @ViewBuilder
    var compareButton: some View {
        if searchViewModel.hasResults {
            Button {
                tappedCompare()
            } label: {
                Label("Compare", systemImage: "rectangle.portrait.on.rectangle.portrait.angled\(isComparing ? ".fill" : "")")
            }
        }
    }
}
