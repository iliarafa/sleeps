import SwiftUI

/// The 24 custom event pictures, drawn in the Big & Loud style.
/// Raw values are what new events store in `CountdownEvent.emoji`
/// (the field name is legacy; see `from(stored:)` for old emoji values).
public enum EventIcon: String, CaseIterable, Identifiable, Sendable {
    case party, cake, tree, pumpkin, gift, plane, beach, sun, ball, coaster,
         tent, movie, balloon, car, gradcap, circus, dog, cat, waves,
         mountain, rocket, star, heart, house

    public var id: String { rawValue }

    public var assetName: String { "icon-\(rawValue)" }

    public var image: Image {
        Image(assetName, bundle: .module)
    }

    /// Resolves a stored string: new rawValues, legacy Apple emoji from
    /// pre-icon builds (synced via CloudKit), and unknown values → .party.
    public static func from(stored: String) -> EventIcon {
        if let icon = EventIcon(rawValue: stored) {
            return icon
        }
        return legacyEmoji[stored] ?? .party
    }

    /// The 24 emoji shipped in pre-icon builds; events synced from those
    /// builds still carry these values in the store.
    private static let legacyEmoji: [String: EventIcon] = [
        "🎉": .party, "🎂": .cake, "🎄": .tree, "🎃": .pumpkin,
        "🎁": .gift, "✈️": .plane, "🏖️": .beach, "⛱️": .sun,
        "⚽️": .ball, "🎢": .coaster, "🏕️": .tent, "🎬": .movie,
        "🎠": .balloon, "🚗": .car, "🎓": .gradcap, "🎪": .circus,
        "🐶": .dog, "🐱": .cat, "🏊": .waves, "⛷️": .mountain,
        "🚀": .rocket, "⭐️": .star, "❤️": .heart, "🏠": .house,
    ]
}
