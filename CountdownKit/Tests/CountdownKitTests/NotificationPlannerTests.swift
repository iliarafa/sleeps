import XCTest
@testable import CountdownKit

final class NotificationPlannerTests: XCTestCase {
    private var cal: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        return cal
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
        cal.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    private let id = UUID()

    func testFarFutureEventGetsAllFourMilestones() {
        let plans = NotificationPlanner.plan(
            eventID: id, title: "Summer Vacation",
            eventDate: date(2026, 8, 1, 12, 0),
            hour: 8, now: date(2026, 7, 14, 10, 0), calendar: cal
        )
        XCTAssertEqual(plans.count, 4)
        XCTAssertEqual(plans.map(\.fireDate), [
            date(2026, 7, 25, 8, 0),  // 7 days before
            date(2026, 7, 29, 8, 0),  // 3 days before
            date(2026, 7, 31, 8, 0),  // 1 day before
            date(2026, 8, 1, 8, 0),   // day of
        ])
    }

    func testNearEventSkipsPastMilestones() {
        // Event in 2 days: the 7- and 3-day milestones are already in the past
        let plans = NotificationPlanner.plan(
            eventID: id, title: "The Beach",
            eventDate: date(2026, 7, 16, 15, 0),
            hour: 8, now: date(2026, 7, 14, 10, 0), calendar: cal
        )
        XCTAssertEqual(plans.map(\.fireDate), [
            date(2026, 7, 15, 8, 0),
            date(2026, 7, 16, 8, 0),
        ])
    }

    func testEventTodayBeforeNotificationTimeGetsDayOfOnly() {
        let plans = NotificationPlanner.plan(
            eventID: id, title: "My Birthday",
            eventDate: date(2026, 7, 14, 18, 0),
            hour: 8, now: date(2026, 7, 14, 6, 0), calendar: cal
        )
        XCTAssertEqual(plans.map(\.fireDate), [date(2026, 7, 14, 8, 0)])
    }

    func testEventTodayAfterNotificationTimeGetsNothing() {
        let plans = NotificationPlanner.plan(
            eventID: id, title: "My Birthday",
            eventDate: date(2026, 7, 14, 18, 0),
            hour: 8, now: date(2026, 7, 14, 9, 0), calendar: cal
        )
        XCTAssertTrue(plans.isEmpty)
    }

    func testMessagesAreKidFriendly() {
        let plans = NotificationPlanner.plan(
            eventID: id, title: "Summer Vacation",
            eventDate: date(2026, 8, 1, 12, 0),
            hour: 8, now: date(2026, 7, 14, 10, 0), calendar: cal
        )
        XCTAssertEqual(plans[0].title, "Summer Vacation")
        XCTAssertEqual(plans[0].body, "7 more sleeps to go!")
        XCTAssertEqual(plans[2].body, "1 more sleep to go!")
        XCTAssertEqual(plans[3].body, "It's today! Hooray! 🎉")
    }

    func testIdsAreStablePerMilestone() {
        let plans = NotificationPlanner.plan(
            eventID: id, title: "X",
            eventDate: date(2026, 8, 1, 12, 0),
            hour: 8, now: date(2026, 7, 14, 10, 0), calendar: cal
        )
        XCTAssertEqual(plans.map(\.id), [
            "\(id.uuidString)-7", "\(id.uuidString)-3", "\(id.uuidString)-1", "\(id.uuidString)-0",
        ])
    }
}
