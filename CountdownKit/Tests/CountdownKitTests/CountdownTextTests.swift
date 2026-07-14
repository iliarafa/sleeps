import XCTest
@testable import CountdownKit

final class CountdownTextTests: XCTestCase {
    // MARK: headline

    func testHeadlineToday() {
        XCTAssertEqual(CountdownText.headline(days: 0), "Today!")
    }

    func testHeadlineFutureIsPlainNumber() {
        XCTAssertEqual(CountdownText.headline(days: 1), "1")
        XCTAssertEqual(CountdownText.headline(days: 12), "12")
    }

    func testHeadlineYesterday() {
        XCTAssertEqual(CountdownText.headline(days: -1), "Yesterday")
    }

    func testHeadlinePast() {
        XCTAssertEqual(CountdownText.headline(days: -3), "3 days ago")
    }

    // MARK: sleeps

    func testSleepsToday() {
        XCTAssertEqual(CountdownText.sleeps(days: 0), "It's today! 🎉")
    }

    func testSleepsSingular() {
        XCTAssertEqual(CountdownText.sleeps(days: 1), "1 more sleep")
    }

    func testSleepsPlural() {
        XCTAssertEqual(CountdownText.sleeps(days: 12), "12 more sleeps")
    }

    func testSleepsPast() {
        XCTAssertEqual(CountdownText.sleeps(days: -1), "was yesterday")
        XCTAssertEqual(CountdownText.sleeps(days: -3), "was 3 days ago")
    }

    // MARK: spoken (Siri)

    func testSpokenFuture() {
        XCTAssertEqual(
            CountdownText.spoken(days: 12, title: "Summer Vacation"),
            "12 days until Summer Vacation — that's 12 more sleeps!"
        )
    }

    func testSpokenSingular() {
        XCTAssertEqual(
            CountdownText.spoken(days: 1, title: "The Beach"),
            "1 day until The Beach — that's 1 more sleep!"
        )
    }

    func testSpokenToday() {
        XCTAssertEqual(
            CountdownText.spoken(days: 0, title: "My Birthday"),
            "My Birthday is today! Hooray! 🎉"
        )
    }

    func testSpokenPast() {
        XCTAssertEqual(
            CountdownText.spoken(days: -1, title: "The Party"),
            "The Party was yesterday."
        )
        XCTAssertEqual(
            CountdownText.spoken(days: -3, title: "The Party"),
            "The Party was 3 days ago."
        )
    }
}
