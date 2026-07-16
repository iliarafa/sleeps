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

    /// Live clock for the final day: "H:MM:SS" (hours un-padded, minutes/seconds
    /// zero-padded). Clamps negatives to zero. e.g. 9 → "0:00:09", 3661 → "1:01:01".
    public static func clock(secondsRemaining: Int) -> String {
        let total = max(0, secondsRemaining)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%d:%02d:%02d", h, m, s)
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
