import SwiftUI
import PrepUnits
import ActivityIndicatorView
import FoodLabel
import SwiftUISugar

struct FoodView: View {
    
    @EnvironmentObject var foodSearchViewModel: FoodSearchViewModel

    var body: some View {
        if let food = foodSearchViewModel.foodBeingPresented {
            foodContents(for: food)
        } else {
            loadingContents
        }
    }
    
    func foodContents(for food: PrepFood) -> some View {
        NavigationView {
            FormStyledScrollView {
                detailSection(for: food)
                foodLabelSection(for: food)
            }
            .navigationTitle("Food")
            .navigationBarTitleDisplayMode(.inline)
        }
        .transition(.move(edge: .top))
    }
    
    func detailSection(for food: PrepFood) -> some View {
        Section {
            VStack(alignment: .center) {
                HStack {
                    Text(food.emoji)
                    Text(food.name)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .bold()
                }
                if let detail = food.detail {
                    Text(detail)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(.quaternarySystemFill))
            )
            .padding(.top)
            .padding(.horizontal)
        }
    }
    
    func foodLabelSection(for food: PrepFood) -> some View {
        FormStyledSection {
            FoodLabel(dataSource: food)
        }
    }
    
    var loadingContents: some View {
        ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
            .frame(width: 70, height: 70)
            .foregroundColor(.secondary)
            .transition(.scale)
    }
}

extension PrepFood: FoodLabelDataSource {
    public var energyValue: FoodLabelValue {
        FoodLabelValue(amount: energy, unit: .kcal)
    }
    
    public var carbAmount: Double {
        carb
    }
    
    public var fatAmount: Double {
        fat
    }
    
    public var proteinAmount: Double {
        protein
    }
    
    public var nutrients: [NutrientType : Double] {
        [:]
    }
    
    public var amountPerString: String {
        "serving"
    }
    
    public var showFooterText: Bool {
        false
    }
}
