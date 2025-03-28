import SwiftUI

enum EditorConfiguration {
    static let accentColor: Color = .blue

    static let primaryBg: Color = .black
    static let panelBg: Color = Color(white: 0.05)
    static let panelBgHover: Color = Color(white: 0.12)

    static let primaryText: Color = .white
    static let secondaryText: Color = Color.white.opacity(0.65)

    static let primaryIcon: Color = Color.white.opacity(0.85)
    static let secondaryIcon: Color = Color.white.opacity(0.55)
    static let iconSelected: Color = accentColor

    static let border: Color = Color.white.opacity(0.42)
    static let divider: Color = Color.white.opacity(0.35)
    static let resizeHandle: Color = Color.white.opacity(0.60)

    static let borderWidth: CGFloat = 0.5

    static let cornerRadius: CGFloat = 6.0
    static let largeCornerRadius: CGFloat = 12.0
    static let smallCornerRadius: CGFloat = 4.0
    static let defaultPadding: CGFloat = 7.0
    static let compactPadding: CGFloat = 4.5
    static let toolButtonSize: CGFloat = 32.0
    static let modeSelectorWidth: CGFloat = 115.0
    static let layersPanelResizeHandleWidth: CGFloat = 8.0

    static let toolsPanelContainerPadding: CGFloat = 16.0

    static let layersPanelDefaultWidthPercentage: CGFloat = 0.45
    static let layersPanelWidthPercentageRange: ClosedRange<CGFloat> = 0.20...0.55

    static func primaryFont(size: CGFloat = 12.5, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
    static func secondaryFont(size: CGFloat = 10.5, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
    static func headerFont(size: CGFloat = 13.5, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight)
    }
    static func iconFont(size: CGFloat = 15, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
    static func buttonFont(size: CGFloat = 12, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight)
    }
    static func smallIconFont(size: CGFloat = 8, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight)
    }
}
