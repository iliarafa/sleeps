import XCTest
@testable import CountdownKit

final class CountdownPhaseTests: XCTestCase {
    private var newYork: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        return cal
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0, in cal: Calendar) -> Date {
        cal.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    // MARK: all-day (no time) — unchanged day-granular behavior

    func testNoTimeTodayIsArrived() {
        let cal = newYork
        let now = date(2026, 7, 14, 9, 0, in: cal)
        let event = date(2026, 7, 14, 20, 0, in: cal) // later today, but no time set
        XCTAssertEqual(CountdownPhase.phase(eventDate: event, hasTime: false, now: now, calendar: cal), .arrived)
    }

    func testNoTimeTomorrowIsSleeps() {
        let cal = newYork
        let now = date(2026, 7, 14, 9, 0, in: cal)
        let event = date(2026, 7, 15, 9, 0, in: cal)
        XCTAssertEqual(CountdownPhase.phase(eventDate: event, hasTime: false, now: now, calendar: cal), .sleeps(1))
    }

    func testNoTimePastIsPast() {
        let cal = newYork
        let now = date(2026, 7, 14, 9, 0, in: cal)
        let event = date(2026, 7, 11, 9, 0, in: cal)
        XCTAssertEqual(CountdownPhase.phase(eventDate: event, hasTime: false, now: now, calendar: cal), .past(-3))
    }

    // MARK: timed

    func testTimedFiveMinutesOutIsTicking() {
        let cal = newYork
        let now = date(2026, 7, 14, 9, 0, in: cal)
        let event = date(2026, 7, 14, 9, 5, in: cal)
        XCTAssertEqual(CountdownPhase.phase(eventDate: event, hasTime: true, now: now, calendar: cal), .ticking(300))
    }

    func testTimedTomorrowMorningWithin24hIsTicking() {
        // now 11 PM tonight, event 8 AM tomorrow = 9h away (< 24h) but calendar-day 1
        let cal = newYork
        let now = date(2026, 7, 14, 23, 0, in: cal)
        let event = date(2026, 7, 15, 8, 0, in: cal)
        XCTAssertEqual(CountdownPhase.phase(eventDate: event, hasTime: true, now: now, calendar: cal), .ticking(9 * 3600))
    }

    func testTimedMoreThan24hIsSleeps() {
        let cal = newYork
        let now = date(2026, 7, 14, 9, 0, in: cal)
        let event = date(2026, 7, 16, 9, 0, in: cal) // 2 days out
        XCTAssertEqual(CountdownPhase.phase(eventDate: event, hasTime: true, now: now, calendar: cal), .sleeps(2))
    }

    func testTimedExactlyNowIsArrived() {
        let cal = newYork
        let now = date(2026, 7, 14, 9, 0, in: cal)
        let event = date(2026, 7, 14, 9, 0, in: cal)
        XCTAssertEqual(CountdownPhase.phase(eventDate: event, hasTime: true, now: now, calendar: cal), .arrived)
    }

    func testTimedEarlierTodayIsArrived() {
        // event time passed but still the same calendar day → celebrate, not past
        let cal = newYork
        let now = date(2026, 7, 14, 15, 0, in: cal)
        let event = date(2026, 7, 14, 9, 0, in: cal)
        XCTAssertEqual(CountdownPhase.phase(eventDate: event, hasTime: true, now: now, calendar: cal), .arrived)
    }

    func testTimedYesterdayIsPast() {
        let cal = newYork
        let now = date(2026, 7, 14, 9, 0, in: cal)
        let event = date(2026, 7, 13, 20, 0, in: cal)
        XCTAssertEqual(CountdownPhase.phase(eventDate: event, hasTime: true, now: now, calendar: cal), .past(-1))
    }
}
