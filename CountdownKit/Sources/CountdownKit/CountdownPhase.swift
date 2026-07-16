import Foundation

/// What the detail screen should show for an event right now. Keeps the branch
/// logic pure and unit-testable (inject `now`/`calendar`), so the view stays thin.
public enum CountdownPhase: Equatable {
    /// Whole days away (> 0) — show "N MORE SLEEPS".
    case sleeps(Int)
    /// Timed event within the final 24h — seconds remaining (0 < s ≤ 86400).
    case ticking(Int)
    /// Today / the event's moment has arrived — celebrate + confetti.
    case arrived
    /// In the past — days (< 0).
    case past(Int)

    /// One second's worth of the count in a day.
    private static let secondsPerDay = 86_400

    public static func phase(
        eventDate: Date,
        hasTime: Bool,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> CountdownPhase {
        let days = DaysUntil.days(from: now, to: eventDate, calendar: calendar)

        guard hasTime else {
            if days > 0 { return .sleeps(days) }
            if days == 0 { return .arrived }
            return .past(days)
        }

        let remaining = eventDate.timeIntervalSince(now)
        if remaining <= 0 {
            return days < 0 ? .past(days) : .arrived
        }
        if remaining <= Double(secondsPerDay) {
            return .ticking(Int(remaining))
        }
        return .sleeps(days)
    }
}
