import Foundation

/// Calendar-day countdown math. The single source of truth for "how many days until".
public enum DaysUntil {
    /// Whole calendar days from `now` to `eventDate`.
    /// Compares start-of-day to start-of-day so time-of-day and DST shifts never matter.
    /// Returns 0 for today, 1 for tomorrow, negative for past days.
    public static func days(from now: Date = .now, to eventDate: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: now)
        let end = calendar.startOfDay(for: eventDate)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }
}
