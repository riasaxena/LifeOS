import SwiftUI

/// Colors and type styles shared across LifeOS, matching the mockups
/// (see the mockups artifact linked from the repo README).
enum Theme {
    static let background = Color(hex: "FAFAF8")
    static let card = Color.white
    static let cardBorder = Color(hex: "ECE9E3")
    static let textPrimary = Color(hex: "1C1B19")
    static let textSecondary = Color(hex: "6B685F")
    static let textMuted = Color(hex: "9A968C")
    static let accent = Color(hex: "D9705A")
    static let accentSoft = Color(hex: "FFF2EE")
    static let success = Color(hex: "4C8C6B")
    static let successSoft = Color(hex: "E9F2ED")
    static let warnSoft = Color(hex: "FFF7F4")
    static let warnBorder = Color(hex: "F0D8CE")

    enum Radius {
        static let card: CGFloat = 16
        static let bigCard: CGFloat = 20
        static let chip: CGFloat = 999
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

/// A rounded card container matching the mockups' card style.
struct CardBackground: ViewModifier {
    var fill: Color = Theme.card
    var border: Color = Theme.cardBorder
    var radius: CGFloat = Theme.Radius.card

    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(fill)
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

extension View {
    func card(fill: Color = Theme.card, border: Color = Theme.cardBorder, radius: CGFloat = Theme.Radius.card) -> some View {
        modifier(CardBackground(fill: fill, border: border, radius: radius))
    }
}
