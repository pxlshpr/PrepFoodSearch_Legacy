import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar

public struct FoodSearch: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ViewModel()
    @State var showingBarcodeScanner = false
    @State var searchIsFocused = false
    @State var showingFilters = false
    
    @State var searchingVerified = false
    @State var searchingDatasets = false
    
    @State var isComparing = false
    
    public init() {
        
    }
    
    public var body: some View {
        searchableView
//            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { trailingContent }
            .toolbar { principalContent }
            .toolbar { leadingToolbar }
            .sheet(isPresented: $showingBarcodeScanner) { barcodeScanner }
            .sheet(isPresented: $showingFilters) { filtersSheet }
            .onChange(of: isComparing) { newValue in
                searchIsFocused = false
            }
    }
    
    var leadingToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button {
                Haptics.feedback(style: .soft)
                dismiss()
            } label: {
                closeButtonLabel
            }
        }
    }
    
    var title: String {
        return isComparing ? "Select Foods to Compare" : "Search"
    }
    
    var principalContent: some ToolbarContent {
        ToolbarItemGroup(placement: .principal) {
            Group {
                if isComparing {
                    Text(title)
                        .font(.headline)
                } else {
                    Picker(selection: $foodType) {
                        Label("Foods", systemImage: "carrot").tag("Foods")
                            .labelStyle(.titleAndIcon)
                        Label("Recipes", systemImage: "note.text").tag("Recipes")
                            .labelStyle(.titleAndIcon)
                        Label("Plates", systemImage: "fork.knife").tag("Plates")
                            .labelStyle(.titleAndIcon)
                    } label: {
                        Text("Hello")
                            .background(Color.green)
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
    
    @State var foodType: String = "Foods"
    var trailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                Haptics.feedback(style: .medium)
                withAnimation {
                    isComparing.toggle()
                }
            } label: {
                Label("Compare", systemImage: "rectangle.portrait.on.rectangle.portrait.angled\(isComparing ? ".fill" : "")")
            }
        }
    }
    
    var searchableView: some View {
        SearchableView(
            searchText: $viewModel.searchText,
            prompt: "Search Foods",
            focused: $searchIsFocused,
            focusOnAppear: true,
            isHidden: $isComparing,
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

struct FoodSearch_Previews: PreviewProvider {
    static var previews: some View {
        FoodSearchPreview()
    }
}
