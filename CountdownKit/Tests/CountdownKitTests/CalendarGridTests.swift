import XCTest
@testable import CountdownKit

final class CalendarGridTests: XCTestCase {
    private func calendar(firstWeekday: Int = 1) -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        cal.firstWeekday = firstWeekday
        return cal
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0, in cal: Calendar) -> Date {
        cal.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    // MARK: cells

    func testJuly2026SundayFirst() {
        // July 1 2026 is a Wednesday → 3 leading nils, then 31 days = 34 cells.
        let cal = calendar(firstWeekday: 1) // Sunday
        let cells = CalendarGrid.cells(monthOf: date(2026, 7, 15, in: cal), calendar: cal)
        XCTAssertEqual(cells.count, 34)
        XCTAssertEqual(cells.prefix(3).filter { $0 == nil }.count, 3)
        XCTAssertNotNil(cells[3])
        XCTAssertEqual(cal.component(.day, from: cells[3]!), 1)
        XCTAssertEqual(cal.component(.day, from: cells.last!!), 31)
    }

    func testJuly2026MondayFirst() {
        // Monday-first: Wednesday is offset 2 → 2 leading nils + 31 = 33 cells.
        let cal = calendar(firstWeekday: 2) // Monday
        let cells = CalendarGrid.cells(monthOf: date(2026, 7, 1, in: cal), calendar: cal)
        XCTAssertEqual(cells.count, 33)
        XCTAssertEqual(cells.prefix(2).filter { $0 == nil }.count, 2)
        XCTAssertEqual(cal.component(.day, from: cells[2]!), 1)
    }

    func testFebruary2026Has28Days() {
        // Feb 1 2026 is a Sunday → 0 leading nils, 28 days.
        let cal = calendar(firstWeekday: 1)
        let cells = CalendarGrid.cells(monthOf: date(2026, 2, 10, in: cal), calendar: cal)
        XCTAssertEqual(cells.compactMap { $0 }.count, 28)
        XCTAssertNotNil(cells.first!)
        XCTAssertEqual(cal.component(.day, from: cells.first!!), 1)
    }

    func testCellsAreStartOfDayAcrossSpringForward() {
        // US DST starts Sun 2026-03-08; every cell should still be local midnight.
        let cal = calendar(firstWeekday: 1)
        let cells = CalendarGrid.cells(monthOf: date(2026, 3, 20, in: cal), calendar: cal)
        for case let day? in cells {
            XCTAssertEqual(cal.component(.hour, from: day), 0)
            XCTAssertEqual(day, cal.startOfDay(for: day))
        }
        XCTAssertEqual(cells.compactMap { $0 }.count, 31)
    }

    // MARK: combine

    func testCombinePreservesTime() {
        let cal = calendar()
        let day = date(2026, 12, 25, 0, 0, in: cal)
        let time = date(2026, 7, 15, 14, 30, in: cal)
        let result = CalendarGrid.combine(day: day, timeOf: time, calendar: cal)
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: result)
        XCTAssertEqual(comps.year, 2026)
        XCTAssertEqual(comps.month, 12)
        XCTAssertEqual(comps.day, 25)
        XCTAssertEqual(comps.hour, 14)
        XCTAssertEqual(comps.minute, 30)
    }

    func testCombineMovingDayKeepsClock() {
        let cal = calendar()
        let original = date(2026, 7, 15, 9, 5, in: cal)
        let newDay = date(2026, 7, 20, 0, 0, in: cal)
        let result = CalendarGrid.combine(day: newDay, timeOf: original, calendar: cal)
        XCTAssertEqual(cal.component(.day, from: result), 20)
        XCTAssertEqual(cal.component(.hour, from: result), 9)
        XCTAssertEqual(cal.component(.minute, from: result), 5)
    }
}
