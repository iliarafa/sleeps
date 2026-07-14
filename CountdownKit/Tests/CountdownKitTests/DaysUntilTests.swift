import XCTest
@testable import CountdownKit

final class DaysUntilTests: XCTestCase {
    private var newYork: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        return cal
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0, in cal: Calendar) -> Date {
        cal.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    func testSameDayIsZeroRegardlessOfTime() {
        let cal = newYork
        let now = date(2026, 7, 14, 0, 1, in: cal)
        let event = date(2026, 7, 14, 23, 59, in: cal)
        XCTAssertEqual(DaysUntil.days(from: now, to: event, calendar: cal), 0)
    }

    func testTomorrowIsOneEvenMinutesApart() {
        let cal = newYork
        let now = date(2026, 7, 14, 23, 59, in: cal)
        let event = date(2026, 7, 15, 0, 1, in: cal)
        XCTAssertEqual(DaysUntil.days(from: now, to: event, calendar: cal), 1)
    }

    func testAcrossSpringForwardDST() {
        // US DST starts 2026-03-08: Mar 7 noon -> Mar 9 is 2 calendar days but only ~1.96 * 86400 seconds
        let cal = newYork
        let now = date(2026, 3, 7, 12, 0, in: cal)
        let event = date(2026, 3, 9, 0, 0, in: cal)
        XCTAssertEqual(DaysUntil.days(from: now, to: event, calendar: cal), 2)
    }

    func testAcrossFallBackDST() {
        // US DST ends 2026-11-01
        let cal = newYork
        let now = date(2026, 10, 31, 12, 0, in: cal)
        let event = date(2026, 11, 2, 12, 0, in: cal)
        XCTAssertEqual(DaysUntil.days(from: now, to: event, calendar: cal), 2)
    }

    func testPastEventIsNegative() {
        let cal = newYork
        let now = date(2026, 7, 14, 8, 0, in: cal)
        let event = date(2026, 7, 13, 22, 0, in: cal)
        XCTAssertEqual(DaysUntil.days(from: now, to: event, calendar: cal), -1)
    }

    func testYearRollover() {
        let cal = newYork
        let now = date(2026, 12, 30, 18, 0, in: cal)
        let event = date(2027, 1, 2, 9, 0, in: cal)
        XCTAssertEqual(DaysUntil.days(from: now, to: event, calendar: cal), 3)
    }
}
