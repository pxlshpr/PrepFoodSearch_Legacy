
import SwiftUI
import SwiftHaptics
import ActivityIndicatorView
import Camera

extension FoodSearch {

    var resultsContents: some View {
        Group {
            ForEach(viewModel.results) { result in
                Button {
                    Haptics.feedback(style: .soft)
                    searchIsFocused = false
                } label: {
                    FoodCell(result: result)
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
            if let barcode = barcodes.first {
                viewModel.searchText = barcode.string
            }
//            Task {
//                let food = try await viewModel.search(for: barcodes)
//                await MainActor.run {
//                    self.foodToPresent = food
//                }
//            }
        }
    }
    
    var list_legacy: some View {
        List {
            resultsContents
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: 66)
        }
        .listStyle(.plain)
    }
        
    var list: some View {
        List {
            Section(header: myFoodsHeader) {
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
            }
            Section(header: verifiedHeader) {
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                Group {
                    if searchingVerified {
                        HStack {
                            ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                                .frame(width: 27, height: 27)
                                .foregroundColor(.secondary)
                                .offset(y: -2)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Button {
                            Haptics.feedback(style: .rigid)
                            searchingVerified = true
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 30))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            Section(header: publicDatasetsHeader) {
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                Group {
                    if searchingDatasets {
                        HStack {
                            ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                                .frame(width: 27, height: 27)
                                .foregroundColor(.secondary)
                                .offset(y: -2)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Button {
                            Haptics.feedback(style: .rigid)
                            searchingDatasets = true
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 30))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: 66)
        }
        .listStyle(.sidebar)
    }
    
    var myFoodsHeader: some View {
        HStack {
//            Image(systemName: "person.fill")
//                .foregroundColor(.secondary)
            Text("My Foods")
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


import SwiftUI
import PrepViews

public struct FoodCell: View {
    
    @Binding var isComparing: Bool
    
    let emoji: String
    let name: String
    let detail: String?
    let brand: String?
    let carb: Double
    let fat: Double
    let protein: Double
    
    let nameWeight: Font.Weight
    let detailWeight: Font.Weight = .regular
    let brandWeight: Font.Weight = .regular
    
    let nameColor: Color = Color(.label)
    let detailColor: Color = Color(.secondaryLabel)
    let brandColor: Color = Color(.tertiaryLabel)
    
    @State var isSelected: Bool = false

    public init(
        isComparing: Binding<Bool>,
        emoji: String,
        name: String,
        detail: String? = nil,
        brand: String? = nil,
        carb: Double,
        fat: Double,
        protein: Double,
        nameFontWeight: Font.Weight = .medium
    ) {
        _isComparing = isComparing
        self.emoji = emoji
        self.name = name
        self.detail = detail
        self.brand = brand
        self.carb = carb
        self.fat = fat
        self.protein = protein
        self.nameWeight = nameFontWeight
    }
    
    public var body: some View {
        HStack {
            selectionButton
            emojiText
            nameTexts
            Spacer()
            macrosIndicator
        }
        .listRowBackground(Color(.secondarySystemGroupedBackground))
    }
    
    @ViewBuilder
    var selectionButton: some View {
        if isComparing {
            Button {
                Haptics.feedback(style: .soft)
                withAnimation {
                    isSelected.toggle()
                }
            } label: {
                Image(systemName: isSelected ? "circle.inset.filled" : "circle")
                    .foregroundColor(isSelected ? Color.accentColor : Color(.quaternaryLabel))
            }
        }
    }
    
    @ViewBuilder
    var emojiText: some View {
        Text(emoji)
    }
    
    var nameTexts: some View {
        var view = Text(name)
            .font(.body)
            .fontWeight(nameWeight)
            .foregroundColor(nameColor)
        if let detail = detail, !detail.isEmpty {
            view = view
            + Text(", ")
                .font(.callout)
                .fontWeight(detailWeight)
                .foregroundColor(detailColor)
            + Text(detail)
                .font(.callout)
                .fontWeight(detailWeight)
                .foregroundColor(detailColor)
        }
        if let brand = brand, !brand.isEmpty {
            view = view
            + Text(", ")
                .font(.callout)
                .fontWeight(brandWeight)
                .foregroundColor(brandColor)
            + Text(brand)
                .font(.callout)
                .fontWeight(brandWeight)
                .foregroundColor(brandColor)
        }
        view = view

        .font(.callout)
        .fontWeight(.semibold)
        .foregroundColor(.secondary)
        
        return view
            .alignmentGuide(.listRowSeparatorLeading) { dimensions in
                dimensions[.leading]
            }
    }
    
    var macrosIndicator: some View {
        MacrosIndicator(c: carb, f: fat, p: protein)
    }
}


struct FoodCellPreview: View {
    
    struct CompactFood {
        let emoji, name : String
        var detail: String? = nil
        var brand: String? = nil
        let c, f, p: Double
    }
    
    let foods: [CompactFood] = [
        CompactFood(emoji: "🧀", name: "Cheese", c: 3, f: 35, p: 14),
        CompactFood(emoji: "🍚", name: "White Rice", c: 42, f: 1, p: 4),
        CompactFood(emoji: "🧀", name: "Parmesan Cheese", detail: "Shredded", brand: "Emborg Ness", c: 42, f: 1, p: 4),
        CompactFood(emoji: "🧀", name: "Parmesan Cheese", detail: "Big", brand: "Emborg", c: 42, f: 1, p: 4),
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(foods, id: \.name) { food in
                    FoodCell(
                        isComparing: .constant(false),
                        emoji: food.emoji,
                        name: food.name,
                        detail: food.detail,
                        brand: food.brand,
                        carb: food.c,
                        fat: food.f,
                        protein: food.p
                    )
                }
            }
            .navigationTitle("Foods")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct FoodCell_Previews: PreviewProvider {
    static var previews: some View {
        FoodCellPreview()
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
