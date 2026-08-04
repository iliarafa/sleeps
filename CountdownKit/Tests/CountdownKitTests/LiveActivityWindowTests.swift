import XCTest
@testable import CountdownKit

final class LiveActivityWindowTests: XCTestCase {
    func testOneSleepAway() {
        let cal = Calendar(identifier: .gregorian)
        let now = cal.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 9))!
        let event = cal.date(from: DateComponents(year: 2026, month: 8, day: 5, hour: 12))!
        XCTAssertTrue(LiveActivityWindow.shouldPresent(eventDate: event, hasTime: false, now: now, calendar: cal))
    }

    func testFarAwayFalse() {
        let cal = Calendar(identifier: .gregorian)
        let now = cal.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 9))!
        let event = cal.date(from: DateComponents(year: 2026, month: 8, day: 20, hour: 12))!
        XCTAssertFalse(LiveActivityWindow.shouldPresent(eventDate: event, hasTime: false, now: now, calendar: cal))
    }

    func testTickingTimedEvent() {
        let cal = Calendar(identifier: .gregorian)
        let now = cal.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 12))!
        let event = cal.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 18))!
        XCTAssertTrue(LiveActivityWindow.shouldPresent(eventDate: event, hasTime: true, now: now, calendar: cal))
    }

    /// Today, all-day (no time): `days == 0`, not `== 1`, and `.arrived` isn't `.ticking` — should be false.
    func testAllDayTodayFalse() {
        let cal = Calendar(identifier: .gregorian)
        let now = cal.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 9))!
        let event = cal.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 12))!
        XCTAssertFalse(LiveActivityWindow.shouldPresent(eventDate: event, hasTime: false, now: now, calendar: cal))
    }

    /// A timed event more than 24h out is `.sleeps`, not `.ticking`, and isn't exactly 1 day away either.
    func testTimedEventFarAwayFalse() {
        let cal = Calendar(identifier: .gregorian)
        let now = cal.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 9))!
        let event = cal.date(from: DateComponents(year: 2026, month: 8, day: 10, hour: 12))!
        XCTAssertFalse(LiveActivityWindow.shouldPresent(eventDate: event, hasTime: true, now: now, calendar: cal))
    }

    /// Past events should never present, even if a stray "1 day" diff could arise from odd input.
    func testPastEventFalse() {
        let cal = Calendar(identifier: .gregorian)
        let now = cal.date(from: DateComponents(year: 2026, month: 8, day: 4, hour: 9))!
        let event = cal.date(from: DateComponents(year: 2026, month: 8, day: 1, hour: 12))!
        XCTAssertFalse(LiveActivityWindow.shouldPresent(eventDate: event, hasTime: false, now: now, calendar: cal))
    }
}
