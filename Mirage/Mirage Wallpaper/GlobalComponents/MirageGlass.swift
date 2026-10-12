import SwiftUI

private struct MirageGlassModifier<S: Shape>: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let shape: S
    let fallback: AnyShapeStyle
    let interactive: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if reduceTransparency {
            content.background(.background, in: shape)
        } else if #available(macOS 26.0, *) {
            content.glassEffect(.regular.interactive(interactive), in: shape)
        } else {
            content.background(fallback, in: shape)
        }
    }
}

/// Content stays flat; Liquid Glass is reserved for floating controls.
enum MirageDesign {
    static let sectionDividerColor = Color(white: 0.8)
    static let contentPadding: CGFloat = 20
    static let cardRadius: CGFloat = 12
    static let minimumWindowWidth: CGFloat = 820
    static let minimumWindowHeight: CGFloat = 600
}

struct WallpaperCardSurface: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let selected: Bool
    let hovered: Bool

    func body(content: Content) -> some View {
        content
            .background(selected ? Color.accentColor.opacity(0.10) : Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: MirageDesign.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: MirageDesign.cardRadius)
                    .strokeBorder(selected ? Color.accentColor : Color.primary.opacity(hovered ? 0.22 : 0.08),
                                  lineWidth: selected ? 2 : 1)
                    .allowsHitTesting(false)
            }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: hovered)
            .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}

extension View {
    func mirageGlass<S: Shape>(in shape: S, fallback: AnyShapeStyle, interactive: Bool = true) -> some View {
        modifier(MirageGlassModifier(shape: shape, fallback: fallback, interactive: interactive))
    }
}
