import Foundation
import PrepDataTypes

public extension Food {
    init(mockName name: String, emoji: String, detail: String? = nil, brand: String? = nil) {
        let energy = Double.random(in: 30...500)
        let carb = Double.random(in: 0...100)
        let fat = Double.random(in: 0...100)
        let protein = Double.random(in: 0...100)
        
        self.init(
            id: UUID(),
            type: .food,
            name: name,
            emoji: emoji,
            detail: detail,
            brand: brand,
            numberOfTimesConsumedGlobally: 0,
            numberOfTimesConsumed: 0,
            lastUsedAt: nil,
            firstUsedAt: nil,
            info: .init(
                amount: .init(value: 1, unitType: .serving),
                nutrients: .init(
                    energyInKcal: energy,
                    carb: carb,
                    protein: protein,
                    fat: fat,
                    micros: []),
                sizes: [],
                barcodes: []
            ),
            publishStatus: .hidden,
            jsonSyncStatus: .synced,
            childrenFoods: nil,
            dataset: nil,
            barcodes: nil,
            syncStatus: .synced,
            updatedAt: 0,
            deletedAt: nil
        )
    }
}
