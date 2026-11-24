import SwiftUI

/// One copyable symbol. `glyph` is exactly what gets typed or copied,
/// the same character the Starpaste website copies.
struct AstroSymbol: Identifiable, Hashable {
    let glyph: String
    let name: String
    /// Extra info shown on bigger tiles, like "120°" for a trine.
    let detail: String?
    /// Short label for the small keyboard tiles.
    let keyLabel: String
    /// True for symbols that are meant to look like colorful emoji (🌕, ✨).
    let isEmoji: Bool

    var id: String { glyph }

    /// What we draw on screen. Adding U+FE0E asks iOS for the plain
    /// text look, so ♌ shows as a pastel glyph instead of a purple emoji box.
    var display: String { isEmoji ? glyph : glyph + "\u{FE0E}" }
}

struct SymbolCategory: Identifiable {
    let id: String
    let name: String
    let shortName: String
    let color: Color
    let symbols: [AstroSymbol]

    var icon: AstroSymbol { symbols[0] }
}

private func s(_ glyph: String, _ name: String, _ detail: String? = nil,
               key: String? = nil, emoji: Bool = false) -> AstroSymbol {
    AstroSymbol(glyph: glyph, name: name, detail: detail, keyLabel: key ?? name, isEmoji: emoji)
}

enum Starpaste {
    // Same list and order as the website (index.html). Edit here to add or remove symbols.
    private static let raw: [(id: String, name: String, short: String, symbols: [AstroSymbol])] = [
        ("planets", "Planets & Luminaries", "Planets", [
            s("☉", "Sun"), s("☽", "Moon"), s("☿", "Mercury"), s("♀", "Venus"), s("♂", "Mars"),
            s("♃", "Jupiter"), s("♄", "Saturn"), s("♅", "Uranus"), s("♆", "Neptune"), s("♇", "Pluto"),
        ]),
        ("zodiac", "Zodiac Signs", "Zodiac", [
            s("♈", "Aries"), s("♉", "Taurus"), s("♊", "Gemini"), s("♋", "Cancer"),
            s("♌", "Leo"), s("♍", "Virgo"), s("♎", "Libra"), s("♏", "Scorpio"),
            s("♐", "Sagittarius", key: "Sag"), s("♑", "Capricorn", key: "Cap"),
            s("♒", "Aquarius", key: "Aqua"), s("♓", "Pisces"),
        ]),
        ("major-aspects", "Major Aspects", "Aspects", [
            s("☌", "Conjunction", "0°", key: "Conjunct"), s("⚹", "Sextile", "60°"),
            s("□", "Square", "90°"), s("△", "Trine", "120°"), s("☍", "Opposition", "180°", key: "Opposite"),
        ]),
        ("minor-aspects", "Minor Aspects", "Minor", [
            s("⚺", "Semi-sextile", "30°", key: "Semi-sext"), s("⚻", "Quincunx", "150°"),
        ]),
        ("points", "Points & Moons", "Points", [
            s("☊", "North Node", key: "N. Node"), s("☋", "South Node", key: "S. Node"),
            s("⚸", "Black Moon Lilith", key: "Lilith"), s("⊗", "Part of Fortune", key: "Fortune"),
        ]),
        ("asteroids", "Asteroids & Centaurs", "Asteroids", [
            s("⚳", "Ceres"), s("⚴", "Pallas"), s("⚵", "Juno"), s("⚶", "Vesta"), s("⚷", "Chiron"),
        ]),
        ("elements", "Elements", "Elements", [
            s("🜂", "Fire"), s("🜃", "Earth"), s("🜁", "Air"), s("🜄", "Water"),
        ]),
        ("moon-phases", "Moon Phases", "Moons", [
            s("🌑", "New Moon", key: "New", emoji: true),
            s("🌒", "Waxing Crescent", key: "Wax. Cres.", emoji: true),
            s("🌓", "First Quarter", key: "1st Qtr", emoji: true),
            s("🌔", "Waxing Gibbous", key: "Wax. Gib.", emoji: true),
            s("🌕", "Full Moon", key: "Full", emoji: true),
            s("🌖", "Waning Gibbous", key: "Wan. Gib.", emoji: true),
            s("🌗", "Last Quarter", key: "Last Qtr", emoji: true),
            s("🌘", "Waning Crescent", key: "Wan. Cres.", emoji: true),
        ]),
        ("extras", "Chart Extras", "Extras", [
            s("℞", "Retrograde", key: "Retro"), s("☄", "Comet"), s("☀", "Sun (rays)", key: "Sun rays"),
        ]),
        ("sparkles", "Stars & Sparkles", "Sparkles", [
            s("★", "Star"), s("☆", "Star (outline)", key: "Outline"), s("✦", "Sparkle"),
            s("✧", "Sparkle (outline)", key: "Outline"), s("⋆", "Tiny Star", key: "Tiny"),
            s("✩", "Outlined Star", key: "Outlined"), s("✨", "Sparkles", emoji: true),
            s("🌙", "Crescent Moon", key: "Crescent", emoji: true), s("🪐", "Ringed Planet", key: "Planet", emoji: true),
            s("🌟", "Glowing Star", key: "Glowing", emoji: true), s("💫", "Dizzy Star", key: "Dizzy", emoji: true),
        ]),
        ("alt-forms", "Alternate Glyphs", "Alt", [
            s("☾", "Moon (waning)", key: "Moon alt"), s("⛢", "Uranus (astronomical)", key: "Uranus alt"),
        ]),
    ]

    static let categories: [SymbolCategory] = raw.enumerated().map { index, c in
        SymbolCategory(id: c.id, name: c.name, shortName: c.short,
                       color: Theme.pastels[index % Theme.pastels.count], symbols: c.symbols)
    }

    private static let byGlyph: [String: (AstroSymbol, Color)] = {
        var map: [String: (AstroSymbol, Color)] = [:]
        for category in categories {
            for symbol in category.symbols where map[symbol.glyph] == nil {
                map[symbol.glyph] = (symbol, category.color)
            }
        }
        return map
    }()

    static func symbol(for glyph: String) -> AstroSymbol? { byGlyph[glyph]?.0 }
    static func color(for glyph: String) -> Color { byGlyph[glyph]?.1 ?? Theme.butter }
}
