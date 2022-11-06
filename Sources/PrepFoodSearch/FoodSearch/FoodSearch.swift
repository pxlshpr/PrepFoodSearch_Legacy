import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar
import ActivityIndicatorView
import Camera

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
            Section {
                Text("Search over 1 million foods in our database.")
                .foregroundColor(.secondary)
                .listRowSeparator(.hidden)
            }
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
        myFoodsSection
    }
    
    var myFoodsSection: some View {
        Section("My Foods") {
            loadingCell
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
