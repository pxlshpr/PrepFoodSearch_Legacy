import SwiftUI
import SwiftHaptics
import SwiftUISugar
import PrepUnits

struct FoodSearchResultCell: View {
    
    let searchResult: FoodSearchResult
    
    var body: some View {
        HStack {
            emojiText
            nameTexts
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .listRowBackground(listRowBackground)
    }
    
    var listRowBackgroundColor: Color {
        Color(.secondarySystemGroupedBackground)
    }
    
    var listRowBackground: some View {
        Color.white
            .colorMultiply(listRowBackgroundColor)
    }
    
    var emojiText: some View {
        Text(searchResult.emoji)
            .font(.body)
    }
    
    var nameTexts: some View {
        var view = Text(searchResult.name)
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
        if let detail = searchResult.detail, !detail.isEmpty {
            view = view
            + Text(", ")
                .font(.callout)
                .foregroundColor(.secondary)
            + Text(detail)
                .font(.callout)
                .foregroundColor(.secondary)
        }
        if let brand = searchResult.brand, !brand.isEmpty {
            view = view
            + Text(", ")
                .font(.callout)
                .foregroundColor(Color(.tertiaryLabel))
            + Text(brand)
                .font(.callout)
                .foregroundColor(Color(.tertiaryLabel))
        }
        
        return view
            .alignmentGuide(.listRowSeparatorLeading) { dimensions in
                dimensions[.leading]
            }
    }
}


struct FoodSearchResultCellPreview: View {
    
    var body: some View {
        NavigationView {
            List {
                FoodSearchResultCell(searchResult: .init(
                    id: UUID(),
                    name: "Gold Emblem",
                    emoji: "🍬",
                    detail: "Fruit Flavored Snacks!, Green Apple, Grape, Black Cherry, Orange, Green Apple, Grape, Black Cherry, Orange",
                    brand: "Cvs Pharmacy, Inc.")
                )
                FoodSearchResultCell(searchResult: .init(
                    id: UUID(),
                    name: "Golden Beer Battered White Meat Chicken Strip Shaped Patties With Mashed Potatoes And Mixed Vegetables - Includes A Chocolate Brownie",
                    emoji: "🍬",
                    detail: "Beer Battered Chicken",
                    brand: "Campbell Soup Company")
                )
                FoodSearchResultCell(searchResult: .init(
                    id: UUID(),
                    name: "Golden Brown All Natural Pork Sausage Patties",
                    emoji: "🥧",
                    detail: "Mild, Minimum 18 Patties/Bag, 28 Oz.",
                    brand: "Jones Dairy Farm")
                )
            }
        }
    }
}

struct FoodSearchResultCell_Previews: PreviewProvider {
    static var previews: some View {
        FoodSearchResultCellPreview()
    }
}
