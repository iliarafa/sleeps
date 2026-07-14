import SwiftUI

/// Small curated palette kids pick from. Stored by name so it survives CloudKit sync.
public enum EventColor: String, CaseIterable, Identifiable {
    case blue, purple, pink, red, orange, green, teal

    public var id: String { rawValue }

    public var color: Color {
        switch self {
        case .blue: .blue
        case .purple: .purple
        case .pink: .pink
        case .red: .red
        case .orange: .orange
        case .green: .green
        case .teal: .teal
        }
    }

    public static func named(_ name: String) -> EventColor {
        EventColor(rawValue: name) ?? .blue
    }
}
