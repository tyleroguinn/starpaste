import SwiftUI

final class KeyboardModel: ObservableObject {
    @Published var showsGlobe = true
    @Published private(set) var recentGlyphs: [String] = []
    @Published var currentSection: String = ""
    @Published private(set) var lastTyped: AstroSymbol?

    var insertText: (String) -> Void = { _ in }
    var deleteBackward: () -> Void = {}
    var nextKeyboard: () -> Void = {}

    private let recentsKey = "recentGlyphs"
    private let maxRecents = 14
    private var lastTypedToken = 0

    init() { reloadRecents() }

    var recentSymbols: [AstroSymbol] { recentGlyphs.compactMap(Starpaste.symbol(for:)) }

    /// Recents are only reshuffled when the keyboard opens, so tiles
    /// never jump around under your finger while you're typing.
    func reloadRecents() {
        recentGlyphs = UserDefaults.standard.stringArray(forKey: recentsKey) ?? []
    }

    func type(_ symbol: AstroSymbol) {
        insertText(symbol.glyph)

        var saved = UserDefaults.standard.stringArray(forKey: recentsKey) ?? []
        saved.removeAll { $0 == symbol.glyph }
        saved.insert(symbol.glyph, at: 0)
        UserDefaults.standard.set(Array(saved.prefix(maxRecents)), forKey: recentsKey)

        lastTyped = symbol
        lastTypedToken += 1
        let token = lastTypedToken
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self, self.lastTypedToken == token else { return }
            self.lastTyped = nil
        }
    }
}

// MARK: - Keyboard layout

struct KeyboardView: View {
    @ObservedObject var model: KeyboardModel

    private struct KeySection: Identifiable {
        let id: String
        let name: String
        let shortName: String
        let iconText: String
        let color: Color
        let symbols: [AstroSymbol]
    }

    private var sections: [KeySection] {
        var list: [KeySection] = []
        let recents = model.recentSymbols
        if !recents.isEmpty {
            list.append(KeySection(id: "recent", name: "Recent", shortName: "Recent",
                                iconText: "☆\u{FE0E}", color: Theme.butter, symbols: recents))
        }
        for category in Starpaste.categories {
            list.append(KeySection(id: category.id, name: category.name, shortName: category.shortName,
                                iconText: category.icon.display, color: category.color,
                                symbols: category.symbols))
        }
        return list
    }

    var body: some View {
        let sections = self.sections
        let active = sections.contains { $0.id == model.currentSection } ? model.currentSection : (sections.first?.id ?? "")

        ScrollViewReader { gridProxy in
            VStack(spacing: 6) {
                categoryBar(sections: sections, active: active) { id in
                    model.currentSection = id
                    withAnimation(.easeInOut(duration: 0.25)) {
                        gridProxy.scrollTo("section-\(id)", anchor: .top)
                    }
                }

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(sections) { section in
                            sectionView(section)
                                .id("section-\(section.id)")
                                .background(GeometryReader { geo in
                                    Color.clear.preference(key: SectionOffsetKey.self,
                                                           value: [section.id: geo.frame(in: .named("grid")).minY])
                                })
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
                .coordinateSpace(name: "grid")
                .onPreferenceChange(SectionOffsetKey.self) { offsets in
                    // The highlighted chip is the last section whose top has scrolled past the top edge.
                    var current = sections.first?.id ?? ""
                    for section in sections {
                        if let y = offsets[section.id], y <= 24 { current = section.id }
                    }
                    if current != model.currentSection { model.currentSection = current }
                }

                bottomRow
            }
            .padding(.top, 6)
            .padding(.bottom, 4)
        }
        .background(
            ZStack {
                Theme.skyGradient
                StarField(density: 3500)
            }
            .ignoresSafeArea()
        )
        .environment(\.colorScheme, .dark)
    }

    // MARK: Category chips

    private func categoryBar(sections: [KeySection], active: String, onSelect: @escaping (String) -> Void) -> some View {
        ScrollViewReader { chipProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(sections) { section in
                        let isOn = section.id == active
                        Button { onSelect(section.id) } label: {
                            HStack(spacing: 4) {
                                Text(section.iconText).font(.system(size: 14))
                                Text(section.shortName).font(Theme.rounded(12))
                            }
                            .foregroundColor(isOn ? Theme.chipInk : section.color)
                            .padding(.horizontal, 10)
                            .frame(height: 28)
                            .background(Capsule().fill(isOn ? section.color : section.color.opacity(0.16)))
                        }
                        .buttonStyle(.plain)
                        .id("chip-\(section.id)")
                        .accessibilityLabel(section.name)
                    }
                }
                .padding(.horizontal, 8)
            }
            .onChange(of: active) { newValue in
                withAnimation(.easeInOut(duration: 0.2)) {
                    chipProxy.scrollTo("chip-\(newValue)", anchor: .center)
                }
            }
        }
        .frame(height: 30)
    }

    // MARK: Symbol grid

    private func sectionView(_ section: KeySection) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Circle().fill(section.color).frame(width: 6, height: 6)
                    .shadow(color: section.color, radius: 4)
                Text(section.name).font(Theme.rounded(12)).foregroundColor(section.color)
            }
            .padding(.leading, 2)
            .accessibilityAddTraits(.isHeader)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50, maximum: 90), spacing: 6)], spacing: 6) {
                ForEach(section.symbols) { symbol in
                    let color = section.id == "recent" ? Starpaste.color(for: symbol.glyph) : section.color
                    Button { model.type(symbol) } label: {
                        VStack(spacing: 1) {
                            Text(symbol.display)
                                .font(.system(size: 24))
                                .foregroundColor(color)
                                .frame(height: 30)
                            Text(symbol.keyLabel)
                                .font(Theme.rounded(9))
                                .foregroundColor(Theme.inkSoft)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .padding(.horizontal, 2)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .buttonStyle(TileStyle(color: color))
                    .accessibilityLabel(symbol.name)
                }
            }
        }
    }

    // MARK: Bottom row

    private var bottomRow: some View {
        HStack(spacing: 6) {
            if model.showsGlobe {
                KeyButton(action: model.nextKeyboard) {
                    Image(systemName: "globe").font(.system(size: 18, weight: .semibold))
                }
                .frame(width: 46)
                .accessibilityLabel("Next keyboard")
            }

            KeyButton(action: { model.insertText(" ") }) {
                if let symbol = model.lastTyped {
                    HStack(spacing: 5) {
                        Text(symbol.display).font(.system(size: 16))
                        Text(symbol.name).font(Theme.rounded(14))
                    }
                    .foregroundColor(Theme.butter)
                    .lineLimit(1)
                } else {
                    Text("space").font(Theme.rounded(14, .bold)).foregroundColor(Theme.inkSoft)
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Space")

            DeleteKey(action: model.deleteBackward)
                .frame(width: 54)

            KeyButton(action: { model.insertText("\n") }) {
                Image(systemName: "return").font(.system(size: 17, weight: .semibold))
            }
            .frame(width: 62)
            .accessibilityLabel("Return")
        }
        .frame(height: 42)
        .padding(.horizontal, 8)
    }
}

private struct SectionOffsetKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]
    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// MARK: - Key styles

private struct TileStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(configuration.isPressed ? Theme.tilePressed : Theme.tile)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(configuration.isPressed ? color : Theme.tileLine, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .contentShape(Rectangle())
    }
}

private struct KeyBackground: View {
    var pressed: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(pressed ? Theme.tilePressed : Color.white.opacity(0.11))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Theme.tileLine, lineWidth: 1)
            )
    }
}

private struct KeyStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Theme.ink)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(KeyBackground(pressed: configuration.isPressed))
            .contentShape(Rectangle())
    }
}

private struct KeyButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: action, label: label)
            .buttonStyle(KeyStyle())
    }
}

/// Delete key: tap to delete one character, hold to keep deleting.
private struct DeleteKey: View {
    let action: () -> Void
    @State private var isPressed = false
    @State private var repeatTimer: Timer?

    var body: some View {
        Image(systemName: isPressed ? "delete.left.fill" : "delete.left")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(Theme.ink)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(KeyBackground(pressed: isPressed))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressed else { return }
                        isPressed = true
                        action()
                        startRepeating()
                    }
                    .onEnded { _ in stopRepeating() }
            )
            .onDisappear { stopRepeating() }
            .accessibilityElement()
            .accessibilityLabel("Delete")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { action() }
    }

    private func startRepeating() {
        repeatTimer?.invalidate()
        let action = self.action
        let isPressed = $isPressed
        let timerBinding = $repeatTimer
        repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: false) { _ in
            guard isPressed.wrappedValue else { return }
            timerBinding.wrappedValue = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
                action()
            }
        }
    }

    private func stopRepeating() {
        isPressed = false
        repeatTimer?.invalidate()
        repeatTimer = nil
    }
}
