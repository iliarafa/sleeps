import AppIntents
import WidgetKit

/// Widget configuration: pick a specific countdown, or leave empty for "next up".
struct SelectEventIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Choose Countdown"
    static let description = IntentDescription("Pick which countdown the widget shows. Leave empty to always show the next one coming up.")

    @Parameter(title: "Countdown")
    var event: CountdownEventEntity?
}
