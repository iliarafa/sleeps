import Foundation

public struct EventImportPayload: Codable, Equatable, Sendable {
    public var version: Int
    public var title: String
    public var date: Date
    public var hasTime: Bool
    public var iconRaw: String
    public var colorName: String

    public init(version: Int = 1, title: String, date: Date, hasTime: Bool, iconRaw: String, colorName: String) {
        self.version = version
        self.title = title
        self.date = date
        self.hasTime = hasTime
        self.iconRaw = iconRaw
        self.colorName = colorName
    }
}

public enum EventImportError: Error {
    case invalidURL
    case unsupportedVersion
}

public enum EventImport {
    public static let currentVersion = 1

    /// HTTPS landing page that redirects into `sleeps://import…`.
    /// Share this (not the bare custom scheme) so Messages / Mail / AirDrop appear.
    public static let publicShareBase = "https://iliarafa.github.io/sleeps/i/"

    public static func makePayload(from event: CountdownEvent) -> EventImportPayload {
        EventImportPayload(
            version: currentVersion,
            title: event.title,
            date: event.date,
            hasTime: event.hasTime,
            iconRaw: event.icon.rawValue,
            colorName: event.colorName
        )
    }

    /// Kid-facing line for share sheets that support a message body.
    public static func shareMessage(for event: CountdownEvent) -> String {
        "\(event.title) — \(CountdownText.sleeps(days: event.daysRemaining))"
    }

    /// Encodes the payload query value shared by deep links and the public HTTPS URL.
    public static func encodedPayload(_ payload: EventImportPayload) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// App deep link: `sleeps://import?d=…`
    public static func url(for payload: EventImportPayload) throws -> URL {
        var components = URLComponents()
        components.scheme = "sleeps"
        components.host = "import"
        components.queryItems = [URLQueryItem(name: "d", value: try encodedPayload(payload))]
        guard let url = components.url else { throw EventImportError.invalidURL }
        return url
    }

    /// Public HTTPS link for the system share sheet (Messages, Mail, AirDrop, …).
    public static func publicShareURL(for payload: EventImportPayload) throws -> URL {
        var components = URLComponents(string: publicShareBase)!
        components.queryItems = [URLQueryItem(name: "d", value: try encodedPayload(payload))]
        guard let url = components.url else { throw EventImportError.invalidURL }
        return url
    }

    public static func payload(from url: URL) throws -> EventImportPayload {
        let isAppImport = url.scheme == "sleeps" && url.host == "import"
        let isPublicImport = url.scheme == "https"
            && url.host == "iliarafa.github.io"
            && url.path.hasPrefix("/sleeps/i")
        guard isAppImport || isPublicImport else {
            throw EventImportError.invalidURL
        }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let b64url = components?.queryItems?.first(where: { $0.name == "d" })?.value else {
            throw EventImportError.invalidURL
        }
        var b64 = b64url.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        while b64.count % 4 != 0 { b64.append("=") }
        guard let data = Data(base64Encoded: b64) else { throw EventImportError.invalidURL }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(EventImportPayload.self, from: data)
        guard payload.version == currentVersion else { throw EventImportError.unsupportedVersion }
        return payload
    }

    public static func makeEvent(from payload: EventImportPayload) -> CountdownEvent {
        let icon = EventIcon.from(stored: payload.iconRaw)
        let event = CountdownEvent(
            title: payload.title,
            date: payload.date,
            emoji: icon.rawValue,
            colorName: payload.colorName
        )
        event.hasTime = payload.hasTime
        // CountdownEvent.init already assigns a new UUID
        return event
    }
}
