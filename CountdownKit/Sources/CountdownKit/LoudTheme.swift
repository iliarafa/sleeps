import SwiftUI

/// "Big & Loud" design system: toy-box graphic design — flat saturated slabs,
/// thick ink outlines, hard offset shadows, flashcard numerals.
public enum Loud {
    public static let ink = Color(red: 0.098, green: 0.098, blue: 0.098)     // #191919
    public static let paper = Color(red: 1.0, green: 0.988, blue: 0.949)     // #FFFCF2
    public static let sun = Color(red: 1.0, green: 0.722, blue: 0.0)         // #FFB800

    /// Poster numerals and titles.
    public static func heavy(_ size: CGFloat) -> Font { .custom("AvenirNext-Heavy", size: size) }
    /// Buttons, labels.
    public static func bold(_ size: CGFloat) -> Font { .custom("AvenirNext-Bold", size: size) }
    /// Dates, captions.
    public static func demi(_ size: CGFloat) -> Font { .custom("AvenirNext-DemiBold", size: size) }
}

public extension View {
    /// The signature slab: flat fill, 3pt ink outline, hard offset ink shadow.
    func loudBox(_ fill: Color, radius: CGFloat = 18, shadow: CGFloat = 5) -> some View {
        background {
            RoundedRectangle(cornerRadius: radius)
                .fill(fill)
                .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(Loud.ink, lineWidth: 3))
                .background(RoundedRectangle(cornerRadius: radius).fill(Loud.ink).offset(x: shadow, y: shadow))
        }
    }

    /// Hard ink drop for big numerals — no blur, pure offset.
    func inkShadow(_ offset: CGFloat = 3) -> some View {
        shadow(color: Loud.ink, radius: 0, x: offset, y: offset)
    }
}

/// White outlined circle holding an event icon.
public struct LoudChip: View {
    let icon: EventIcon
    let size: CGFloat

    public init(icon: EventIcon, size: CGFloat = 48) {
        self.icon = icon
        self.size = size
    }

    public var body: some View {
        icon.image
            .resizable()
            .scaledToFit()
            .frame(width: size * 0.66, height: size * 0.66)
            .frame(width: size, height: size)
            .background(Circle().fill(Loud.paper))
            .overlay(Circle().strokeBorder(Loud.ink, lineWidth: 3))
    }
}
