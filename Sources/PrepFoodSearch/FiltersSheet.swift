import SwiftUI
import SwiftUISugar
import SwiftHaptics

struct FilterButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var filter: Filter
    @Binding var onlyOneFilterSelectedInGroup: Bool
    let didTap: () -> ()
    
    var body: some View {
        toggle
//        button
    }
    
    var isOnlySelectedFilterInGroup: Bool {
        onlyOneFilterSelectedInGroup && filter.isSelected
    }
    
    var toggle: some View {
        let isOn = Binding<Bool>(
            get: {
                /// Always show as toggled if this is the only selected filter in the group
                guard !isOnlySelectedFilterInGroup else {
                    return true
                }
                return filter.isSelected
            },
            set: {
                guard !isOnlySelectedFilterInGroup else {
                    return
                }
                filter.isSelected = $0
            }
        )

        return Toggle(isOn: isOn) {
            HStack {
                optionalImage
                Text(filter.name)
            }
            .frame(height: 25)
        }
        .toggleStyle(.button)
        .buttonStyle(.bordered)
        .tint(filter.isSelected ? .accentColor : .gray)
    }
    
    @ViewBuilder
    var optionalImage: some View {
        if let systemImage {
            Image(systemName: systemImage)
                .foregroundColor(systemImageColor)
                .frame(height: 25)
        }
    }
    
    var button: some View {
        Button {
            withAnimation {
                filter.toggle()
            }
            didTap()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .foregroundColor(backgroundColor(for: colorScheme))
                HStack(spacing: 5) {
                    optionalImage
                    Text(filter.name)
                        .foregroundColor(filter.isSelected ? .white : .primary)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
            }
            .fixedSize(horizontal: true, vertical: true)
            .contentShape(Rectangle())
        }
//        .grayscale(filter.isSelected ? 1 : 0)
    }
    
    var systemImageColor: Color? {
        guard let selectedColor = filter.selectedSystemImageColor, filter.isSelected else {
            return nil
        }
        return selectedColor
    }
    
    var systemImage: String? {
        if filter.isSelected, let selectedSystemImage = filter.selectedSystemImage {
            return selectedSystemImage
        } else {
            return filter.systemImage
        }
    }
    
    func backgroundColor(for colorScheme: ColorScheme) -> Color {
        let selectionColorDark = Color(hex: "6c6c6c")
        let selectionColorLight = Color(hex: "959596")
        
        guard filter.isSelected else {
            return Color(.secondarySystemFill)
        }
        return colorScheme == .light ? selectionColorLight : selectionColorDark
    }
}

extension Array where Element == Filter {
    var selectedCount: Int {
        filter({ $0.isSelected }).count
    }
}
class FiltersSheetViewModel: ObservableObject {
    @Published var databaseFilters: [Filter] = allDatabases {
        didSet {
            withAnimation {
                onlyOneDatabaseIsSelected = databaseFilters.selectedCount == 1
                footerText = getFooterText()
            }
        }
    }
    @Published var typeFilters: [Filter] = allTypes {
        didSet {
            withAnimation {
                onlyOneTypeIsSelected = typeFilters.selectedCount == 1
                footerText = getFooterText()
            }
        }
    }
    @Published var onlyOneDatabaseIsSelected: Bool
    @Published var onlyOneTypeIsSelected: Bool
    @Published var footerText: Text
    
    init() {
        //TODO: Read in and set defaults here
        self.databaseFilters = allDatabases
        self.typeFilters = allTypes
        self.onlyOneDatabaseIsSelected = allDatabases.selectedCount == 1
        self.onlyOneTypeIsSelected = allTypes.selectedCount == 1
        self.footerText = Text("")
    }
    
    var foodsCount: Int {
        //TODO: Get this from the backend
        /// We should store these values in UserDefaults.
        /// Update it silently in the background whenever the app or this sheet is opened.
        let verifiedFoods = 13543
        let verifiedRecipes = 523
        let verifiedPlates = 93
        let myFoods = 154
        let myRecipes = 12
        let myPlates = 4
        let usdaFoods = 381939
        let usdaRecipes = 0
        let usdaPlates = 0
        let ausnutFoods = 5740
        let ausnutRecipes = 0
        let ausnutPlates = 0
        
        var count = 0
        if verifiedSelected {
            if foodsSelected { count += verifiedFoods }
            if recipesSelected { count += verifiedRecipes }
            if platesSelected { count += verifiedPlates }
        }
        if yourDatabaseSelected {
            if foodsSelected { count += myFoods }
            if recipesSelected { count += myRecipes }
            if platesSelected { count += myPlates }
        }
        if usdaSelected {
            if foodsSelected { count += usdaFoods }
            if recipesSelected { count += usdaRecipes }
            if platesSelected { count += usdaPlates }
        }
        if ausnutSelected {
            if foodsSelected { count += ausnutFoods }
            if recipesSelected { count += ausnutRecipes }
            if platesSelected { count += ausnutPlates }
        }
        return count
    }
    
    var typesSuffix: String {
        if foodsSelected {
            if recipesSelected {
                if platesSelected {
                    return "foods, recipes and plates"
                } else {
                    return "foods and recipes"
                }
            } else if platesSelected {
                return "foods and plates"
            } else {
                return "foods"
            }
        } else {
            if recipesSelected {
                if platesSelected {
                    return "recipes and plates"
                } else {
                    return "recipes"
                }
            } else {
                return "plates"
            }
        }
    }

    func getFooterText() -> Text {
        Text("You are searching \(foodsCount) \(typesSuffix).")
    }
    
    var verifiedSelected: Bool {
        databaseFilters.first(where: { $0.name == "Verified" })?.isSelected == true
    }
    var yourDatabaseSelected: Bool {
        databaseFilters.first(where: { $0.name == "Your Database" })?.isSelected == true
    }
    var usdaSelected: Bool {
        databaseFilters.first(where: { $0.name == "USDA" })?.isSelected == true
    }
    var ausnutSelected: Bool {
        databaseFilters.first(where: { $0.name == "AUSNUT" })?.isSelected == true
    }

    var foodsSelected: Bool {
        typeFilters.first(where: { $0.name == "Foods" })?.isSelected == true
    }
    var platesSelected: Bool {
        typeFilters.first(where: { $0.name == "Plates" })?.isSelected == true
    }
    var recipesSelected: Bool {
        typeFilters.first(where: { $0.name == "Recipes" })?.isSelected == true
    }
}

struct FiltersSheet: View {
    
    @StateObject var viewModel = FiltersSheetViewModel()

    init() { }
    
    var body: some View {
        NavigationView {
            FormStyledScrollView {
                FormStyledSection(header: Text("Databases")) {
                    databasesSection
                }
                FormStyledSection(header: Text("Types"), footer: footer) {
                    typesSection
                }
            }
            .onAppear(perform: appeared)
            .navigationTitle("Search Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.height(400)])
        .presentationDragIndicator(.hidden)
    }
    
    func appeared() {
        viewModel.footerText = viewModel.getFooterText()
    }
    
    var footer: some View {
        viewModel.footerText
    }
    
    var databasesSection: some View {
        FlowLayout(
            mode: .scrollable,
            items: viewModel.databaseFilters,
            itemSpacing: 4,
            shouldAnimateHeight: .constant(false)
        ) {
            databaseButton(for: $0)
        }
    }

    var typesSection: some View {
        FlowLayout(
            mode: .scrollable,
            items: viewModel.typeFilters,
            itemSpacing: 4,
            shouldAnimateHeight: .constant(false)
        ) {
            typeButton(for: $0)
        }
    }

    @ViewBuilder
    func databaseButton(for database: Filter) -> some View {
        if let index = viewModel.databaseFilters.firstIndex(where: { $0.id == database.id }) {
            FilterButton(
                filter: $viewModel.databaseFilters[index],
                onlyOneFilterSelectedInGroup: $viewModel.onlyOneDatabaseIsSelected) {
            }
            .buttonStyle(.borderless)
        }
    }
    
    @ViewBuilder
    func typeButton(for database: Filter) -> some View {
        if let index = viewModel.typeFilters.firstIndex(where: { $0.id == database.id }) {
            FilterButton(
                filter: $viewModel.typeFilters[index],
                onlyOneFilterSelectedInGroup: $viewModel.onlyOneTypeIsSelected) {
            }
            .buttonStyle(.borderless)
        }
    }

}

var allDatabases: [Filter] = [
    Filter(
        name: "Verified",
        systemImage: "checkmark.seal",
        selectedSystemImage: "checkmark.seal.fill",
        selectedSystemImageColor: .blue,
        isSelected: true
    ),
    Filter(
        name: "Your Database",
        systemImage: "person",
        selectedSystemImage: "person.fill",
        isSelected: true
    ),
    Filter(
        name: "USDA",
        systemImage: "text.book.closed",
        selectedSystemImage: "text.book.closed.fill"
    ),
    Filter(
        name: "AUSNUT",
        systemImage: "text.book.closed",
        selectedSystemImage: "text.book.closed.fill"
    )
]

var allTypes: [Filter] = [
    Filter(
        name: "Foods",
        systemImage: "carrot",
        selectedSystemImage: "carrot.fill",
        isSelected: true
    ),
    Filter(
        name: "Recipes",
        systemImage: "note.text"
    ),
    Filter(
        name: "Plates",
        systemImage: "fork.knife"
    )
]

struct Filter: Identifiable {
    var id = UUID().uuidString
    var name: String
    var systemImage: String? = nil
    var selectedSystemImage: String? = nil
    var selectedSystemImageColor: Color? = nil
    var isSelected: Bool = false {
        didSet {
            Haptics.feedback(style: .soft)
        }
    }
    
    mutating func toggle() {
        Haptics.feedback(style: .soft)
        isSelected.toggle()
    }
}

struct FiltersSheetPreview: View {
    var body: some View {
        FiltersSheet()
    }
}

struct FiltersSheet_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Color.clear
                .navigationTitle("Search")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: .constant(true)) {
                    FiltersSheetPreview()
                }
        }
    }
}
