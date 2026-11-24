import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}

/// The same pastel night-sky colors as the website.
enum Theme {
    static let skyTop = Color(hex: 0x1D1747)
    static let skyBottom = Color(hex: 0x2B1F5C)
    static let ink = Color(hex: 0xF6F1FF)
    static let inkSoft = Color(hex: 0xC9BDF0)
    static let chipInk = Color(hex: 0x2A1D55)
    static let tile = Color.white.opacity(0.07)
    static let tilePressed = Color.white.opacity(0.18)
    static let tileLine = Color(hex: 0xDCCDFF, opacity: 0.18)

    static let lilac = Color(hex: 0xCDB6FF)
    static let peach = Color(hex: 0xFFC7A8)
    static let mint = Color(hex: 0xA8F0D4)
    static let pink = Color(hex: 0xFFB3D9)
    static let butter = Color(hex: 0xFFF0A3)
    static let sky = Color(hex: 0xA9D8FF)
    static let toast = Color(hex: 0xFFF6FB)
    static let toastInk = Color(hex: 0x3A2470)

    /// Category colors, in the same rotation as the website.
    static let pastels: [Color] = [lilac, pink, peach, mint, sky, butter]

    static let skyGradient = LinearGradient(colors: [skyTop, skyBottom], startPoint: .top, endPoint: .bottom)
    static let titleGradient = LinearGradient(colors: [pink, lilac, sky], startPoint: .leading, endPoint: .trailing)

    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

/// A sprinkle of soft, tinted stars. Always draws the same pattern so it doesn't jump around.
struct StarField: View {
    var density: CGFloat = 5000

    var body: some View {
        Canvas { context, size in
            var rng = SeededRandom(seed: 20_241_124)
            let tints: [Color] = [.white, Color(hex: 0xFFD6F0), Color(hex: 0xD6C8FF), Color(hex: 0xFFF0BE)]
            let count = Int(size.width * size.height / density)
            for _ in 0..<count {
                let x = CGFloat(rng.next()) * size.width
                let y = CGFloat(rng.next()) * size.height
                let r = CGFloat(rng.next() * 1.3 + 0.3)
                let alpha: Double = 0.3 + rng.next() * 0.6
                let tint = tints[Int(rng.next() * Double(tints.count)) % tints.count]
                context.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                             with: .color(tint.opacity(alpha)))
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct SeededRandom {
    private var state: UInt64
    init(seed: UInt64) { state = seed }

    /// A number from 0 up to (but not including) 1.
    mutating func next() -> Double {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Double(state >> 11) / 9_007_199_254_740_992.0
    }
}
