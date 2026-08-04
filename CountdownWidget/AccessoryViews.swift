import SwiftUI
import WidgetKit
import CountdownKit

struct AccessoryCircularView: View {
    let event: EventSnapshot

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            if event.days > 0 {
                Text("\(event.days)")
                    .font(Loud.heavy(24))
                    .minimumScaleFactor(0.5)
            } else {
                Text("NOW")
                    .font(Loud.heavy(14))
            }
        }
        .widgetURL(deepLink(for: event))
    }
}

struct AccessoryRectangularView: View {
    let event: EventSnapshot

    var body: some View {
        HStack(spacing: 6) {
            LoudChip(icon: event.icon, size: 24)
            VStack(alignment: .leading, spacing: 0) {
                Text(event.title)
                    .font(Loud.heavy(12))
                    .lineLimit(1)
                Text(event.days > 0 ? "\(event.days) sleeps" : "Today!")
                    .font(Loud.demi(11))
                    .lineLimit(1)
            }
        }
        .widgetURL(deepLink(for: event))
    }
}

struct AccessoryInlineView: View {
    let event: EventSnapshot

    var body: some View {
        ViewThatFits {
            Text(event.days > 0 ? "\(event.days) sleeps · \(event.title)" : "Today! · \(event.title)")
            Text(event.days > 0 ? "\(event.days) sleeps" : "Today!")
        }
        .widgetURL(deepLink(for: event))
    }
}
