import XCTest
@testable import CountdownKit

final class EventIconTests: XCTestCase {
    func testResolvesNewRawValues() {
        XCTAssertEqual(EventIcon.from(stored: "cake"), .cake)
        XCTAssertEqual(EventIcon.from(stored: "rocket"), .rocket)
    }

    func testResolvesAllLegacyEmoji() {
        // The exact 24 emoji shipped in pre-icon builds.
        let legacy: [String: EventIcon] = [
            "🎉": .party, "🎂": .cake, "🎄": .tree, "🎃": .pumpkin,
            "🎁": .gift, "✈️": .plane, "🏖️": .beach, "⛱️": .sun,
            "⚽️": .ball, "🎢": .coaster, "🏕️": .tent, "🎬": .movie,
            "🎠": .balloon, "🚗": .car, "🎓": .gradcap, "🎪": .circus,
            "🐶": .dog, "🐱": .cat, "🏊": .waves, "⛷️": .mountain,
            "🚀": .rocket, "⭐️": .star, "❤️": .heart, "🏠": .house,
        ]
        for (emoji, expected) in legacy {
            XCTAssertEqual(EventIcon.from(stored: emoji), expected, "\(emoji) should map to \(expected)")
        }
    }

    func testUnknownValueFallsBackToParty() {
        XCTAssertEqual(EventIcon.from(stored: "🦖"), .party)
        XCTAssertEqual(EventIcon.from(stored: ""), .party)
        XCTAssertEqual(EventIcon.from(stored: "not-an-icon"), .party)
    }

    func testEveryCaseHasAnAssetName() {
        for icon in EventIcon.allCases {
            XCTAssertEqual(icon.assetName, "icon-\(icon.rawValue)")
        }
    }
}
