import Foundation
import PrepDataTypes

extension FoodSearch {
    var title: String {
        return isComparing ? "Select \(searchViewModel.foodType.description)s to Compare" : "Search"
    }
}
