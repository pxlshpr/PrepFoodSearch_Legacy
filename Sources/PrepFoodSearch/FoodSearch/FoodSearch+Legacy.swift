import SwiftUI
import ActivityIndicatorView
import SwiftHaptics
import PrepDataTypes

enum ResultGroupType {
    case myFoods
    case verified
    case datasets
}

struct ResultGroup {
    let type: ResultGroupType
    let results: [FoodSearchResult] = []
}

extension FoodSearch {
    var listContents_legacy: some View {
        Group {
            Section("My Foods") {
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
            }
            Section(header: verifiedHeader) {
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                Group {
                    if !isComparing {
                        if searchingVerified {
                            HStack {
                                ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                                    .frame(width: 27, height: 27)
                                    .foregroundColor(.secondary)
                                    .offset(y: -2)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Button {
                                Haptics.feedback(style: .rigid)
                                searchingVerified = true
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 30))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            Section(header: publicDatasetsHeader) {
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                FoodCell(isComparing: $isComparing, emoji: "🧀", name: "Cheese", carb: 5, fat: 2, protein: 1)
                Group {
                    if !isComparing {
                        if searchingDatasets {
                            HStack {
                                ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                                    .frame(width: 27, height: 27)
                                    .foregroundColor(.secondary)
                                    .offset(y: -2)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Button {
                                Haptics.feedback(style: .rigid)
                                searchingDatasets = true
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 30))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
    }
    
    var resultsContents_legacy: some View {
        Group {
            ForEach(searchManager.results) { result in
                Button {
                    Haptics.feedback(style: .soft)
                    searchIsFocused = false
                } label: {
                    FoodCell(result: result)
                        .buttonStyle(.borderless)
                }
                .onAppear {
                    searchManager.loadMoreContentIfNeeded(currentResult: result)
                }
            }
            if searchManager.isLoadingPage {
                HStack {
                    Spacer()
                    ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                        .frame(width: 50, height: 50)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .listRowSeparator(.hidden)
//                ProgressView()
            }
        }
    }
    
    var list_legacy: some View {
        List {
            resultsContents_legacy
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: 66)
        }
        .listStyle(.plain)
    }
}

