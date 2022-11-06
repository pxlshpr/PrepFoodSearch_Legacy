import SwiftUI
import SwiftUISugar

extension FoodSearch {
    var searchableView: some View {
        SearchableView(
            searchText: $searchManager.searchText,
            prompt: "Search Foods",
            focused: $searchIsFocused,
            focusOnAppear: false,
            isHidden: $isComparing,
            didSubmit: didSubmit,
            buttonViews: {
                EmptyView()
                scanButton
            },
            content: {
//                Color.blue
                list
            })
    }
}

import SwiftUI
import SwiftSugar
import SwiftHaptics

let colorHexKeyboardLight = "CDD0D6"
let colorHexKeyboardDark = "303030"
let colorHexSearchTextFieldDark = "535355"
let colorHexSearchTextFieldLight = "FFFFFF"

public typealias SearchSubmitHandler = (() -> ())

struct MyButtonStyle: ButtonStyle {

  func makeBody(configuration: Self.Configuration) -> some View {
      configuration.label
//          .padding()
//          .foregroundColor(.white)
//          .background(configuration.isPressed ? Color.red : Color.blue)
//          .cornerRadius(8.0)
  }

}

public struct SearchableView<Content: View>: View {

    @Binding var searchText: String
    var externalIsFocused: Binding<Bool>
    let buttonViews: [AnyView]
    var content: () -> Content

    //MARK: Internal
    @Environment(\.colorScheme) var colorScheme
    @FocusState var isFocused: Bool
    @State var showingSearchLayer: Bool = false

    @Binding var isHidden: Bool
    let blurWhileSearching: Bool
    let focusOnAppear: Bool
    let prompt: String

    let didSubmit: SearchSubmitHandler?

    let shrunkenStyle: Bool = true

    public init(
        searchText: Binding<String>,
        prompt: String = "Search",
        focused: Binding<Bool> = .constant(true),
        blurWhileSearching: Bool = false,
        focusOnAppear: Bool = false,
        isHidden: Binding<Bool> = .constant(false),
        didSubmit: SearchSubmitHandler? = nil,
        @ViewBuilder content: @escaping () -> Content)
    {
        _searchText = searchText
        _isHidden = isHidden
        self.prompt = prompt
        self.externalIsFocused = focused
        self.blurWhileSearching = blurWhileSearching
        self.focusOnAppear = focusOnAppear
        self.didSubmit = didSubmit
        self.buttonViews = []
        self.content = content
    }

    public init<Views>(
        searchText: Binding<String>,
        prompt: String = "Search",
        focused: Binding<Bool> = .constant(true),
        blurWhileSearching: Bool = false,
        focusOnAppear: Bool = false,
        isHidden: Binding<Bool> = .constant(false),
        didSubmit: SearchSubmitHandler? = nil,
        @ViewBuilder buttonViews: @escaping () -> TupleView<Views>,
        @ViewBuilder content: @escaping () -> Content)
    {
        _searchText = searchText
        _isHidden = isHidden
        self.prompt = prompt
        self.externalIsFocused = focused
        self.blurWhileSearching = blurWhileSearching
        self.focusOnAppear = focusOnAppear
        self.didSubmit = didSubmit
        self.buttonViews = buttonViews().getViews
        self.content = content
    }

    var bottomInset: CGFloat {
        if isFocused {
            return 370
        } else {
            return searchText.isEmpty ? 0 : 100
        }
    }
    public var body: some View {
        ZStack {
            content()
                .blur(radius: blurRadius)
                .frame(width: UIScreen.main.bounds.width)
                .safeAreaInset(edge: .bottom) {
                    Spacer().frame(height: bottomInset)
                }
                .edgesIgnoringSafeArea(.bottom)
                .interactiveDismissDisabled(isFocused)
            if !isHidden {
                searchLayer
                    .zIndex(10)
                    .transition(.move(edge: .bottom))
            }
        }
//        .frame(width: UIScreen.main.bounds.width)
        .onAppear {
            if focusOnAppear {
                focusOnSearchTextField()
            }
        }
        .onChange(of: externalIsFocused.wrappedValue) { newValue in
            isFocused = newValue
        }
        .onChange(of: isFocused) { newValue in
            externalIsFocused.wrappedValue = newValue
            if blurWhileSearching && !showingSearchLayer && isFocused {
                withAnimation {
                    showingSearchLayer = true
                }
            }
            withAnimation {
                buttonIsFocused = newValue
            }
        }
    }

    var searchLayer: some View {
        ZStack {
            VStack {
                Spacer()
                searchBar
                    .background(
                        Group {
                            if isFocused {
                                keyboardColor
                                    .edgesIgnoringSafeArea(.bottom)
                            }
                        }
                    )
            }
        }
    }

    @Namespace var namespace
    @State var buttonIsFocused = false

    var shouldShowSearchBarBackground: Bool {
        !searchText.isEmpty || buttonIsFocused
    }
    
    var isExpanded: Bool {
        buttonIsFocused || !searchText.isEmpty
    }
    
    /// Shrunken
    var searchBar: some View {
        ZStack {
            if isExpanded {
                searchBarBackground
            }
            Button {
                Haptics.feedback(style: .soft)
                withAnimation {
                    buttonIsFocused = true
                }
                isFocused = true
            } label: {
                searchBarContents
            }
            .padding(.horizontal, 7)
            .buttonStyle(MyButtonStyle())
        }
    }
    
    var textFieldContents: some View {
        HStack(spacing: 5) {
            searchIcon
            ZStack {
                if isExpanded {
                    HStack {
                        textField
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .scaleEffect(buttonIsFocused ? 1 : 0.01)
                            .opacity(isExpanded ? 1 : 0.01)
                        Spacer()
                        clearButton
                    }
                }
                HStack(spacing: 0) {
                    Text("Search")
                        .foregroundColor(Color(.label))
                        .colorMultiply(isExpanded ? Color(.tertiaryLabel) : Color(.secondaryLabel))
                        .opacity(isExpanded ? (searchText.isEmpty ? 1 : 0) : 1)
//                        .padding(.trailing, buttonIsFocused ? 0 : 0)
                        .multilineTextAlignment(.leading)
                        .kerning(0.5)
                    if isExpanded {
                        Text(" Foods")
                            .foregroundColor(Color(.tertiaryLabel))
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .leading)),
                                removal: .move(edge: .trailing).combined(with: .opacity)))
                            .opacity(searchText.isEmpty ? 1 : 0)
                    }
                }
                .frame(maxWidth: isExpanded ? .infinity : 61, alignment: .leading)
            }
        }
    }
        
    var textFieldBackground: some View {
        RoundedRectangle(cornerRadius: isExpanded ? 15 : 20, style: .circular)
            .foregroundColor(isExpanded ? textFieldColor : Color(.tertiarySystemGroupedBackground))
            .frame(height: isExpanded ? 48 : 38)
            .frame(width: isExpanded ? UIScreen.main.bounds.width - 18 : 120)
            .offset(x: isExpanded ? 0 : -20)
            .shadow(color: shadowColor, radius: 3, x: 0, y: 3)
    }

    var shadowColor: Color {
        guard !isExpanded else { return .clear }
        return Color(.black).opacity(colorScheme == .light ? 0.2 : 0.2)
    }
    
    var accessoryViews: some View {
        ForEach(buttonViews.indices, id: \.self) { index in
            buttonViews[index]
                .foregroundColor(Color(.label))
                .colorMultiply(isExpanded ? Color(.secondaryLabel) : Color(.secondaryLabel))
                .padding(6)
                .background(
                    Circle()
                        .foregroundColor(isExpanded ? textFieldColor : Color(.tertiarySystemGroupedBackground))
                        .shadow(color: shadowColor, radius: 3, x: 0, y: 3)
                )
        }
        .offset(x: isExpanded ? 0 : 20)
    }
    
    var searchBarContents: some View {
        ZStack {
            textFieldBackground
            HStack {
                textFieldContents
                accessoryViews
            }
            .padding(.horizontal, 12)
        }
    }

    var blurRadius: CGFloat {
        guard blurWhileSearching else { return 0 }
        return showingSearchLayer ? 10 : 0
    }

    func focusOnSearchTextField() {
        withAnimation {
            showingSearchLayer = true
        }
        isFocused = true
    }

    var keyboardColor: some View {
        Group {
            if !isFocused {
                Color.clear
                    .background(
                        .ultraThinMaterial
                    )
    //            return Color.accentColor
    //                .opacity(0.5)
            } else {
                colorScheme == .light ? Color(hex: colorHexKeyboardLight) : Color(hex: colorHexKeyboardDark)
            }
        }
    }

    var textFieldColor: Color {
        colorScheme == .light ? Color(hex: colorHexSearchTextFieldLight) : Color(hex: colorHexSearchTextFieldDark)
    }

    var textField: some View {
        TextField("", text: $searchText)
            .focused($isFocused)
            .font(.system(size: 18))
            .keyboardType(.alphabet)
            .submitLabel(.search)
            .autocorrectionDisabled()
            .onSubmit {
                if let didSubmit {
                    Haptics.feedback(style: .soft)
                    didSubmit()
                }
//                        guard !searchViewModel.searchText.isEmpty else {
//                            dismiss()
//                            return
//                        }
                resignFocusOfSearchTextField()
//                        startSearching()
            }
    }

    var searchIcon: some View {
        Image(systemName: "magnifyingglass")
            .foregroundColor(Color(.secondaryLabel))
            .font(.system(size: 18))
            .fontWeight(.semibold)
    }

    var clearButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            searchText = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(Color(.quaternaryLabel))
        }
        .opacity((!searchText.isEmpty && isFocused) ? 1 : 0)
    }

    var searchBar_normal: some View {
        ZStack {
            searchBarBackground
            ZStack {
                textFieldBackground
                HStack {
                    HStack(spacing: 5) {
                        searchIcon
                        textField
                        Spacer()
                        clearButton
                    }
                    ForEach(buttonViews.indices, id: \.self) { index in
                        buttonViews[index]
                    }
                }
                .padding(.horizontal, 12)
            }
            .padding(.horizontal, 7)
        }
    }

    var searchBarBackground: some View {
        keyboardColor
            .frame(height: 65)
            .transition(.opacity)
    }

    var searchLayer_normal: some View {
        ZStack {
            VStack {
                Spacer()
                searchBar
                    .background(
                        keyboardColor
                            .edgesIgnoringSafeArea(.bottom)
                    )
            }
        }
    }

    func resignFocusOfSearchTextField() {
        withAnimation {
            showingSearchLayer = false
        }
        isFocused = false
    }
}

extension TupleView {
    var getViews: [AnyView] {
        makeArray(from: value)
    }

    private struct GenericView {
        let body: Any

        var anyView: AnyView? {
            AnyView(_fromValue: body)
        }
    }

    private func makeArray<Tuple>(from tuple: Tuple) -> [AnyView] {
        func convert(child: Mirror.Child) -> AnyView? {
            withUnsafeBytes(of: child.value) { ptr -> AnyView? in
                let binded = ptr.bindMemory(to: GenericView.self)
                return binded.first?.anyView
            }
        }

        let tupleMirror = Mirror(reflecting: tuple)
        return tupleMirror.children.compactMap(convert)
    }
}


struct FoodSearch_Previews: PreviewProvider {
    static var previews: some View {
        FoodSearchPreview()
    }
}

