import XCTest
@testable import CountdownKit

final class WatchEventSnapshotTests: XCTestCase {
    private var cal: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "America/New_York")!
        return c
    }

    private func d(_ y: Int, _ m: Int, _ day: Int) -> Date {
        cal.date(from: DateComponents(year: y, month: m, day: day, hour: 12))!
    }

    private func snapshot(_ title: String, _ date: Date, icon: String = "cake") -> WatchEventSnapshot {
        WatchEventSnapshot(
            id: UUID(),
            title: title,
            iconRaw: icon,
            colorName: "pink",
            date: date,
            hasTime: false
        )
    }

    func testPayloadRoundTripsThroughMessageDictionary() throws {
        let payload = WatchPayload(
            events: [snapshot("Birthday", d(2026, 7, 4))],
            sentAt: d(2026, 7, 1)
        )
        let message = try WatchSnapshotStore.message(for: payload)
        XCTAssertEqual(WatchSnapshotStore.payload(from: message), payload)
    }

    func testMessageValueIsPropertyListSafe() throws {
        let message = try WatchSnapshotStore.message(for: WatchPayload(events: []))
        XCTAssertTrue(message[WatchSnapshotStore.messageKey] is Data)
    }

    func testPayloadFromUnrelatedMessageIsNil() {
        XCTAssertNil(WatchSnapshotStore.payload(from: ["something": 1]))
        XCTAssertNil(WatchSnapshotStore.payload(from: [WatchSnapshotStore.messageKey: Data("junk".utf8)]))
    }

    func testUpcomingDropsPastEventsAndSortsSoonestFirst() {
        let now = d(2026, 7, 1)
        let events = [
            snapshot("Christmas", d(2026, 12, 25)),
            snapshot("Yesterday", d(2026, 6, 30)),
            snapshot("Today", d(2026, 7, 1)),
            snapshot("Camp", d(2026, 7, 10)),
        ]
        let upcoming = WatchEventSnapshot.upcoming(from: events, now: now, calendar: cal)
        XCTAssertEqual(upcoming.map(\.title), ["Today", "Camp", "Christmas"])
    }

    func testUpcomingRespectsLimit() {
        let now = d(2026, 7, 1)
        let events = (1...9).map { snapshot("Event \($0)", d(2026, 7, 1 + $0)) }
        XCTAssertEqual(WatchEventSnapshot.upcoming(from: events, limit: 5, now: now, calendar: cal).count, 5)
    }

    func testDaysRemainingMatchesDaysUntil() {
        let now = d(2026, 7, 1)
        let event = snapshot("Camp", d(2026, 7, 4))
        XCTAssertEqual(event.daysRemaining(from: now, calendar: cal), 3)
    }

    func testIconResolvesLegacyEmoji() {
        XCTAssertEqual(snapshot("Cake", d(2026, 7, 4), icon: "🎂").icon, .cake)
        XCTAssertEqual(snapshot("Junk", d(2026, 7, 4), icon: "nope").icon, .party)
    }
}
