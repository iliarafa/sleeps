import Foundation

/// One phone → Watch push: the short list of upcoming countdowns plus when it was sent.
public struct WatchPayload: Codable, Sendable, Equatable {
    public static let currentVersion = 1

    public var version: Int
    public var events: [WatchEventSnapshot]
    public var sentAt: Date

    public init(events: [WatchEventSnapshot], sentAt: Date = .now, version: Int = WatchPayload.currentVersion) {
        self.version = version
        self.events = events
        self.sentAt = sentAt
    }
}

/// Encoding for the WatchConnectivity payload, plus the Watch-side cache of the
/// last push. The cache lives in the App Group so the complication — a separate
/// process that never sees the session — reads the same numbers as the app.
public enum WatchSnapshotStore {
    /// Key used inside `applicationContext` / `userInfo` dictionaries.
    public static let messageKey = "sleepsPayload"
    private static let defaultsKey = "watch.payload.v1"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: AppIDs.appGroup) ?? .standard
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    public static func encode(_ payload: WatchPayload) throws -> Data {
        try encoder.encode(payload)
    }

    public static func decode(_ data: Data) -> WatchPayload? {
        guard let payload = try? decoder.decode(WatchPayload.self, from: data),
              payload.version == WatchPayload.currentVersion
        else { return nil }
        return payload
    }

    /// Property-list-safe dictionary for `updateApplicationContext` / `transferUserInfo`.
    public static func message(for payload: WatchPayload) throws -> [String: Any] {
        [messageKey: try encode(payload)]
    }

    public static func payload(from message: [String: Any]) -> WatchPayload? {
        guard let data = message[messageKey] as? Data else { return nil }
        return decode(data)
    }

    /// Remembers the newest push. Older pushes are ignored so an out-of-order
    /// `transferUserInfo` backup can't overwrite a fresher applicationContext.
    @discardableResult
    public static func save(_ payload: WatchPayload) -> Bool {
        if let existing = load(), existing.sentAt > payload.sentAt { return false }
        guard let data = try? encode(payload) else { return false }
        defaults.set(data, forKey: defaultsKey)
        return true
    }

    public static func load() -> WatchPayload? {
        guard let data = defaults.data(forKey: defaultsKey) else { return nil }
        return decode(data)
    }
}
