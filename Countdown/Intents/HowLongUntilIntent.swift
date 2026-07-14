import AppIntents
import SwiftUI
import CountdownKit

/// The reason this app exists: "Hey Siri, how long until Summer Vacation in Sleeps?"
struct HowLongUntilIntent: AppIntent {
    static let title: LocalizedStringResource = "How Long Until"
    static let description = IntentDescription("Tells you how many days (sleeps!) are left until an event.")

    @Parameter(title: "Event")
    var event: CountdownEventEntity

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let days = DaysUntil.days(to: event.date)
        let dialog = IntentDialog(stringLiteral: CountdownText.spoken(days: days, title: event.title))
        return .result(dialog: dialog) {
            HowLongSnippetView(icon: event.icon, title: event.title, days: days)
        }
    }
}

private struct HowLongSnippetView: View {
    let icon: EventIcon
    let title: String
    let days: Int

    var body: some View {
        HStack(spacing: 14) {
            icon.image
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(CountdownText.sleeps(days: days))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(CountdownText.headline(days: days))
                .font(.system(size: 40, weight: .heavy, design: .rounded))
        }
        .padding()
    }
}

struct CountdownShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: HowLongUntilIntent(),
            phrases: [
                "How long until \(\.$event) in \(.applicationName)",
                "How many sleeps until \(\.$event) in \(.applicationName)",
                "\(.applicationName), how long until \(\.$event)",
                "\(.applicationName), how many sleeps until \(\.$event)",
            ],
            shortTitle: "How Long Until",
            systemImageName: "calendar.badge.clock"
        )
    }
}
