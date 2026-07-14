import Foundation

/// Kid-friendly phrasing for a countdown, driven by the day count from `DaysUntil`.
public enum CountdownText {
    /// Big display line: "12", "Today!" …
    public static func headline(days: Int) -> String {
        switch days {
        case 0: "Today!"
        case -1: "Yesterday"
        case ..<(-1): "\(-days) days ago"
        default: "\(days)"
        }
    }

    /// Subtitle in "sleeps": "12 more sleeps", "1 more sleep", "It's today!" …
    public static func sleeps(days: Int) -> String {
        switch days {
        case 0: "It's today! 🎉"
        case 1: "1 more sleep"
        case -1: "was yesterday"
        case ..<(-1): "was \(-days) days ago"
        default: "\(days) more sleeps"
        }
    }

    /// Full sentence for Siri to speak: "12 days until Summer Vacation — that's 12 more sleeps!"
    public static func spoken(days: Int, title: String) -> String {
        switch days {
        case 0: "\(title) is today! Hooray! 🎉"
        case 1: "1 day until \(title) — that's 1 more sleep!"
        case -1: "\(title) was yesterday."
        case ..<(-1): "\(title) was \(-days) days ago."
        default: "\(days) days until \(title) — that's \(days) more sleeps!"
        }
    }
}
