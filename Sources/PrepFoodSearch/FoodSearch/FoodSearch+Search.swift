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
            focusOnAppear: focusOnAppear,
            isHidden: $isComparing,
            showKeyboardDismiss: true,
            showDismiss: true,
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
