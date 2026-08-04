import Foundation
import SwiftData

public enum YearlyRepeat {
    /// Returns `date` if still on/after today; otherwise the next future anniversary.
    /// Feb 29 → Feb 28 in non-leap years.
    public static func nextDate(after date: Date, now: Date, calendar: Calendar = .current) -> Date {
        var candidate = date
        while DaysUntil.days(from: now, to: candidate, calendar: calendar) < 0 {
            guard let year = calendar.dateComponents([.year], from: candidate).year else { break }
            var parts = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: candidate)
            parts.year = year + 1
            if parts.month == 2, parts.day == 29,
               let y = parts.year, !isLeapYear(y, calendar: calendar) {
                parts.day = 28
            }
            guard let advanced = calendar.date(from: parts) else { break }
            candidate = advanced
        }
        return candidate
    }

    private static func isLeapYear(_ year: Int, calendar: Calendar) -> Bool {
        var c = DateComponents()
        c.year = year
        c.month = 2
        c.day = 29
        guard let date = calendar.date(from: c) else { return false }
        let resolved = calendar.dateComponents([.year, .month, .day], from: date)
        return resolved.year == year && resolved.month == 2 && resolved.day == 29
    }

    @discardableResult
    public static func advancePastEvents(in context: ModelContext, now: Date = .now, calendar: Calendar = .current) -> Int {
        let all = (try? context.fetch(FetchDescriptor<CountdownEvent>())) ?? []
        var count = 0
        for event in all where event.repeatsYearly {
            let next = nextDate(after: event.date, now: now, calendar: calendar)
            if next != event.date {
                event.date = next
                count += 1
            }
        }
        if count > 0 { try? context.save() }
        return count
    }
}
