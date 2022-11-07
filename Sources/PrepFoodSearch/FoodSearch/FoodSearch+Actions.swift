import Foundation

extension FoodSearch {

    func didSubmit() {
//        searchManager.search()
        Task {
            await searchManager.performNetworkSearch()
        }
    }

    func isComparingChanged(to newValue: Bool) {
        searchIsFocused = false
    }

}
