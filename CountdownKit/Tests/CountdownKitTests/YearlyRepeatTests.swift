import XCTest
@testable import CountdownKit

final class YearlyRepeatTests: XCTestCase {
    private var cal: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "America/New_York")!
        return c
    }

    private func d(_ y: Int, _ m: Int, _ day: Int) -> Date {
        cal.date(from: DateComponents(year: y, month: m, day: day, hour: 12))!
    }

    func testAdvancesPastBirthdayToNextYear() {
        let eventDate = d(2025, 7, 4)
        let now = d(2026, 7, 5)
        let next = YearlyRepeat.nextDate(after: eventDate, now: now, calendar: cal)
        XCTAssertEqual(DaysUntil.days(from: now, to: next, calendar: cal) >= 0, true)
        let parts = cal.dateComponents([.year, .month, .day], from: next)
        XCTAssertEqual(parts.year, 2027)
        XCTAssertEqual(parts.month, 7)
        XCTAssertEqual(parts.day, 4)
    }

    func testDoesNotAdvanceFutureEvent() {
        let eventDate = d(2026, 12, 25)
        let now = d(2026, 7, 5)
        let next = YearlyRepeat.nextDate(after: eventDate, now: now, calendar: cal)
        XCTAssertEqual(next, eventDate)
    }

    func testLeapDayBecomesFeb28InNonLeapYear() {
        // 2024-02-29 advanced when now is 2025-03-01 → 2025-02-28 already past → 2026-02-28
        let eventDate = d(2024, 2, 29)
        let now = d(2025, 3, 1)
        let next = YearlyRepeat.nextDate(after: eventDate, now: now, calendar: cal)
        let parts = cal.dateComponents([.year, .month, .day], from: next)
        XCTAssertEqual(parts.month, 2)
        XCTAssertEqual(parts.day, 28)
        XCTAssertEqual(parts.year, 2026)
    }
}
