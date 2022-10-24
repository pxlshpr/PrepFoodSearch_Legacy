import SwiftUI
import SwiftUISugar
import SwiftHaptics

struct DatabaseButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var database: Database
    let didTap: () -> ()
    
    var body: some View {
        toggle
//        button
    }
    
    var toggle: some View {
        Toggle(isOn: $database.isSelected) {
            HStack {
                optionalImage
                Text(database.name)
            }
            .frame(height: 25)
        }
        .toggleStyle(.button)
        .buttonStyle(.bordered)
        .tint(database.isSelected ? .accentColor : .gray)
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
                database.toggle()
            }
            didTap()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .foregroundColor(backgroundColor(for: colorScheme))
                HStack(spacing: 5) {
                    optionalImage
                    Text(database.name)
                        .foregroundColor(database.isSelected ? .white : .primary)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
            }
            .fixedSize(horizontal: true, vertical: true)
            .contentShape(Rectangle())
        }
//        .grayscale(filter.isSelected ? 1 : 0)
    }
    
    var systemImageColor: Color {
        if let selectedColor = database.selectedSystemImageColor, database.isSelected {
            return selectedColor
        } else {
            return .secondary
        }
    }
    
    var systemImage: String? {
        if database.isSelected, let selectedSystemImage = database.selectedSystemImage {
            return selectedSystemImage
        } else {
            return database.systemImage
        }
    }
    
    func backgroundColor(for colorScheme: ColorScheme) -> Color {
        let selectionColorDark = Color(hex: "6c6c6c")
        let selectionColorLight = Color(hex: "959596")
        
        guard database.isSelected else {
            return Color(.secondarySystemFill)
        }
        return colorScheme == .light ? selectionColorLight : selectionColorDark
    }
}

struct FiltersSheet: View {
    
    @State var databases: [Database] = allDatabases
    
    var body: some View {
        NavigationView {
            FormStyledScrollView {
                FormStyledSection(header: header, footer: footer) {
                    databasesSection
                }
            }
            .navigationTitle("Search Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
    
    var header: some View {
        Text("Databases")
    }
    
    var foodsCount: Int {
        databases.reduce(0) { $0 + ($1.isSelected ? $1.count : 0) }
    }
    
    var footer: some View {
        Text("You are searching through \(foodsCount) foods.")
    }
    
    var databasesSection: some View {
        FlowLayout(
            mode: .scrollable,
            items: databases,
            itemSpacing: 4,
            shouldAnimateHeight: .constant(false)
        ) {
            databaseButton(for: $0)
        }
    }
    
    @ViewBuilder
    func databaseButton(for database: Database) -> some View {
        if let index = databases.firstIndex(where: { $0.id == database.id }) {
            DatabaseButton(database: $databases[index]) {
            }
            .buttonStyle(.borderless)
        }
    }
}

var allDatabases: [Database] = [
    Database(name: "My Foods", count: 768, isSelected: true),
    Database(
        name: "Public Verified",
        count: 12257,
        systemImage: "checkmark.seal",
        selectedSystemImage: "checkmark.seal.fill",
        selectedSystemImageColor: .blue,
        isSelected: true
    ),
    Database(name: "USDA", count: 381939),
    Database(name: "AUSNUT", count: 5740)
]

struct Database: Identifiable {
    var id = UUID().uuidString
    var name: String
    var count: Int
    var systemImage: String? = nil
    var selectedSystemImage: String? = nil
    var selectedSystemImageColor: Color? = nil
    var isSelected: Bool = false {
        didSet {
            Haptics.transientHaptic()
        }
    }
    
    mutating func toggle() {
        Haptics.transientHaptic()
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
