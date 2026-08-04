import XCTest
@testable import CountdownKit

final class EventImportTests: XCTestCase {
    func testRoundTripURLPreservesFields() throws {
        let cal = Calendar(identifier: .gregorian)
        let date = cal.date(from: DateComponents(year: 2026, month: 8, day: 20, hour: 15, minute: 30))!
        let event = CountdownEvent(title: "Summer Camp", date: date, emoji: EventIcon.tent.rawValue, colorName: "green")
        event.hasTime = true
        let payload = EventImport.makePayload(from: event)
        let url = try EventImport.url(for: payload)
        let decoded = try EventImport.payload(from: url)
        XCTAssertEqual(decoded.version, 1)
        XCTAssertEqual(decoded.title, "Summer Camp")
        XCTAssertEqual(decoded.hasTime, true)
        XCTAssertEqual(decoded.iconRaw, "tent")
        XCTAssertEqual(decoded.colorName, "green")
        XCTAssertEqual(DaysUntil.days(from: date, to: decoded.date, calendar: cal), 0)
    }

    func testMakeEventUsesNewUUID() {
        let event = CountdownEvent(title: "A", date: Date(), emoji: "party", colorName: "blue")
        let payload = EventImport.makePayload(from: event)
        let a = EventImport.makeEvent(from: payload)
        let b = EventImport.makeEvent(from: payload)
        XCTAssertNotEqual(a.id, event.id)
        XCTAssertNotEqual(a.id, b.id)
        XCTAssertEqual(a.title, "A")
        XCTAssertEqual(a.emoji, "party")
    }

    func testRejectsWrongScheme() {
        let url = URL(string: "https://example.com/import")!
        XCTAssertThrowsError(try EventImport.payload(from: url))
    }

    func testLocalEventURLIsNotImport() {
        let url = URL(string: "sleeps://event/\(UUID().uuidString)")!
        XCTAssertThrowsError(try EventImport.payload(from: url))
    }
}
