import SwiftUI
import CountdownKit

/// Watch-side type scale. Avenir Next (the phone's poster face) isn't on watchOS,
/// so `Font.custom` would silently fall back to a thin system face — heavy rounded
/// system type keeps the flashcard feel instead.
enum WatchLoud {
    static func heavy(_ size: CGFloat) -> Font { .system(size: size, weight: .heavy, design: .rounded) }
    static func bold(_ size: CGFloat) -> Font { .system(size: size, weight: .bold, design: .rounded) }
    static func demi(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
}

/// "3 SLEEPS" / "TODAY!" — the caption under a day count.
func sleepsCaption(days: Int) -> String {
    switch days {
    case 0: "TODAY!"
    case 1: "SLEEP"
    default: "SLEEPS"
    }
}

extension WatchEventSnapshot {
    var color: Color { EventColor.named(colorName).color }

    var dayLabel: String {
        let days = daysRemaining
        return days == 0 ? "0" : "\(days)"
    }
}
