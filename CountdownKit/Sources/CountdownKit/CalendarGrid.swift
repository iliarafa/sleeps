import Foundation

/// Month-grid math for the custom calendar. Pure and calendar-injectable so the
/// first-weekday offset, month length, and DST boundaries can be unit-tested.
public enum CalendarGrid {
    /// The cells for the month containing `date`: leading `nil`s pad to the
    /// month's first weekday, then one entry (the day's start-of-day) per day.
    public static func cells(monthOf date: Date, calendar: Calendar = .current) -> [Date?] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: date),
            let range = calendar.range(of: .day, in: .month, for: date)
        else { return [] }

        let firstOfMonth = monthInterval.start
        // 0-based offset of the month's first day from the calendar's first weekday.
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let leading = (weekday - calendar.firstWeekday + 7) % 7

        var cells: [Date?] = Array(repeating: nil, count: leading)
        for day in range {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                cells.append(calendar.startOfDay(for: d))
            }
        }
        return cells
    }

    /// `day`'s year/month/day carrying the time-of-day (hour/minute/second) of
    /// `time`, so picking a date on the calendar preserves any time the user set.
    public static func combine(day: Date, timeOf time: Date, calendar: Calendar = .current) -> Date {
        let d = calendar.dateComponents([.year, .month, .day], from: day)
        let t = calendar.dateComponents([.hour, .minute, .second], from: time)
        var comps = DateComponents()
        comps.year = d.year
        comps.month = d.month
        comps.day = d.day
        comps.hour = t.hour
        comps.minute = t.minute
        comps.second = t.second
        return calendar.date(from: comps) ?? day
    }
}
