import Foundation
import PrepDataTypes

extension FoodSearch {
    var title: String {
        return isComparing ? "Select \(searchManager.foodType.description)s to Compare" : "Search"
    }
}
