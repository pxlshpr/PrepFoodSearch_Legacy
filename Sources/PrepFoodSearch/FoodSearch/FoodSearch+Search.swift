import SwiftUI
import SwiftUISugar

extension FoodSearch {
    var searchableView: some View {
        SearchableView(
            searchText: $searchManager.searchText,
            prompt: "Search Foods",
            focused: $searchIsFocused,
            focusOnAppear: false,
            isHidden: $isComparing,
            didSubmit: didSubmit,
            buttonViews: {
//                filterButton
                EmptyView()
                scanButton
            },
            content: {
                list
            })
    }
}
