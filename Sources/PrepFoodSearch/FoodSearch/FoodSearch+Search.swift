import SwiftUI
import SwiftUISugar
import SwiftSugar
import PrepDataTypes

extension FoodSearch {
    var searchableView: some View {
        SearchableView(
            searchText: $searchViewModel.searchText,
            promptSuffix: "Foods",
            focused: $searchIsFocused,
            focusOnAppear: true,
            isHidden: $isComparing,
            didSubmit: didSubmit,
            buttonViews: {
                EmptyView()
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
