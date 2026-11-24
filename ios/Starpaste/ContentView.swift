import SwiftUI
import UIKit

/// The app you open from the home screen: setup steps, a box to try the
/// keyboard, and every symbol as a tap-to-copy tile (just like the website).
struct ContentView: View {
    @State private var tryText = ""
    @State private var toast: (symbol: AstroSymbol, token: Int)?
    @State private var toastCounter = 0
    @Environment(\.openURL) private var openURL

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.skyGradient.ignoresSafeArea()
            StarField().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    header
                    setupCard
                    tryCard
                    ForEach(Starpaste.categories) { category in
                        CategoryGrid(category: category, onCopy: copy)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 64)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)

            if let toast {
                HStack(spacing: 6) {
                    Text(toast.symbol.display).font(.system(size: 18))
                    Text("\(toast.symbol.name) copied!").font(Theme.rounded(15))
                }
                .foregroundColor(Theme.toastInk)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Capsule().fill(Theme.toast))
                .shadow(color: Color(hex: 0x0A0528, opacity: 0.45), radius: 15, y: 8)
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .id(toast.token)
            }
        }
        .foregroundColor(Theme.ink)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(spacing: 10) {
            Text("☽\u{FE0E} ✦ ☉\u{FE0E} ✦ ☾\u{FE0E}")
                .font(.system(size: 20))
                .foregroundColor(Theme.butter)
                .accessibilityHidden(true)
            Text("Starpaste")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.titleGradient)
            Text("Astro symbols, right on your keyboard ✨")
                .font(Theme.rounded(17, .bold))
                .foregroundColor(Theme.inkSoft)
                .multilineTextAlignment(.center)
        }
    }

    private var setupCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Turn on the keyboard")
                .font(Theme.rounded(20, .bold))
                .foregroundColor(Theme.lilac)

            step(1, "Tap **Open Settings** below.")
            step(2, "Tap **Keyboards**, then switch on **Starpaste**.")
            step(3, "In any app, tap the \(Image(systemName: "globe")) key until the Starpaste keyboard shows up. Or hold it and pick Starpaste.")

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            } label: {
                Text("Open Settings")
                    .font(Theme.rounded(16))
                    .foregroundColor(Theme.chipInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Theme.lilac))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(card)
    }

    private func step(_ number: Int, _ text: LocalizedStringKey) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(number)")
                .font(Theme.rounded(13))
                .foregroundColor(Theme.chipInk)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Theme.pastels[(number - 1) % Theme.pastels.count]))
            Text(text)
                .font(Theme.rounded(15, .semibold))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var tryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Try it here")
                .font(Theme.rounded(20, .bold))
                .foregroundColor(Theme.mint)
            TextField("Tap here, then switch to Starpaste", text: $tryText, axis: .vertical)
                .font(.system(size: 20, design: .rounded))
                .lineLimit(1...4)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Theme.tileLine, lineWidth: 1)
                )
        }
        .padding(18)
        .background(card)
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Theme.tileLine, lineWidth: 1)
            )
    }

    private func copy(_ symbol: AstroSymbol) {
        UIPasteboard.general.string = symbol.glyph
        toastCounter += 1
        let token = toastCounter
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            toast = (symbol, token)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            guard toast?.token == token else { return }
            withAnimation(.easeOut(duration: 0.2)) { toast = nil }
        }
    }
}

private struct CategoryGrid: View {
    let category: SymbolCategory
    let onCopy: (AstroSymbol) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Circle().fill(category.color).frame(width: 10, height: 10)
                    .shadow(color: category.color, radius: 6)
                Text(category.name)
                    .font(Theme.rounded(22, .semibold))
                    .foregroundColor(category.color)
                Text("\(category.symbols.count)")
                    .font(Theme.rounded(13, .bold))
                    .foregroundColor(Theme.inkSoft)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 10)], spacing: 10) {
                ForEach(category.symbols) { symbol in
                    Button { onCopy(symbol) } label: {
                        VStack(spacing: 5) {
                            Text(symbol.display)
                                .font(.system(size: 36))
                                .foregroundColor(category.color)
                                .frame(height: 44)
                            Text(symbol.name)
                                .font(Theme.rounded(13))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                            if let detail = symbol.detail {
                                Text(detail)
                                    .font(Theme.rounded(11, .bold))
                                    .foregroundColor(Theme.inkSoft)
                            }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 6)
                        .frame(maxWidth: .infinity, minHeight: 104)
                    }
                    .buttonStyle(CopyTileStyle(color: category.color))
                    .accessibilityLabel("Copy \(symbol.name)")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CopyTileStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Theme.ink)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(configuration.isPressed ? Theme.tilePressed : Theme.tile)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(configuration.isPressed ? color : Theme.tileLine, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
