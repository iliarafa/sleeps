import SwiftUI

/// Small curated palette kids pick from. Stored by name so it survives CloudKit sync.
public enum EventColor: String, CaseIterable, Identifiable {
    case blue, purple, pink, red, orange, green, teal

    public var id: String { rawValue }

    /// Flat, saturated toy-box palette — every color carries white type.
    public var color: Color {
        switch self {
        case .blue: Color(red: 0.176, green: 0.424, blue: 0.874)   // #2D6CDF
        case .purple: Color(red: 0.439, green: 0.282, blue: 0.910) // #7048E8
        case .pink: Color(red: 1.0, green: 0.302, blue: 0.553)     // #FF4D8D
        case .red: Color(red: 1.0, green: 0.294, blue: 0.243)      // #FF4B3E
        case .orange: Color(red: 1.0, green: 0.541, blue: 0.0)     // #FF8A00
        case .green: Color(red: 0.0, green: 0.659, blue: 0.471)    // #00A878
        case .teal: Color(red: 0.0, green: 0.690, blue: 0.780)     // #00B0C7
        }
    }

    public static func named(_ name: String) -> EventColor {
        EventColor(rawValue: name) ?? .blue
    }
}
