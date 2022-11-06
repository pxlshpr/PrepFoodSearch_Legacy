import Foundation

extension FoodSearch {

    func didSubmit() {
        searchManager.search()
    }

    func isComparingChanged(to newValue: Bool) {
        searchIsFocused = false
    }

}
