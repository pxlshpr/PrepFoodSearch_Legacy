import SwiftUI

extension FoodSearch {

    func didSubmit() {
        withAnimation {
            shouldShowSearchPrompt = false
        }
        Task {
            await searchManager.performNetworkSearch()
        }
    }

    func isComparingChanged(to newValue: Bool) {
        searchIsFocused = false
    }

}
