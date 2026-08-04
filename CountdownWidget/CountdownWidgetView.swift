import WidgetKit
import SwiftUI
import CountdownKit

struct CountdownWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CountdownEntry

    var body: some View {
        content
            .containerBackground(for: .widget) { background }
    }

    @ViewBuilder
    private var content: some View {
        if entry.events.isEmpty {
            emptyView
        } else {
            switch family {
            case .systemMedium:
                MediumView(events: entry.events)
            case .accessoryCircular:
                AccessoryCircularView(event: entry.events[0])
            case .accessoryRectangular:
                AccessoryRectangularView(event: entry.events[0])
            case .accessoryInline:
                AccessoryInlineView(event: entry.events[0])
            default:
                SmallView(event: entry.events[0])
            }
        }
    }

    @ViewBuilder
    private var background: some View {
        if entry.events.isEmpty {
            if isAccessoryFamily {
                AccessoryWidgetBackground()
            } else {
                Loud.paper
            }
        } else if family == .systemMedium {
            Rectangle().fill(.ultraThinMaterial)
        } else if isAccessoryFamily {
            AccessoryWidgetBackground()
        } else {
            EventColor.named(entry.events[0].colorName).color
        }
    }

    private var isAccessoryFamily: Bool {
        switch family {
        case .accessoryCircular, .accessoryRectangular, .accessoryInline:
            true
        default:
            false
        }
    }

    @ViewBuilder
    private var emptyView: some View {
        if isAccessoryFamily {
            accessoryEmptyView
        } else {
            homeEmptyView
        }
    }

    @ViewBuilder
    private var accessoryEmptyView: some View {
        switch family {
        case .accessoryCircular:
            Text("+")
                .font(Loud.heavy(16))
        case .accessoryRectangular:
            Text("SLEEPS")
                .font(Loud.heavy(12))
                .lineLimit(1)
        case .accessoryInline:
            Text("SLEEPS")
                .lineLimit(1)
        default:
            Text("SLEEPS")
                .font(Loud.heavy(12))
                .lineLimit(1)
        }
    }

    private var homeEmptyView: some View {
        VStack(spacing: 6) {
            Text("🗓️").font(.title)
            Text("ADD A COUNTDOWN!")
                .font(Loud.heavy(11))
                .foregroundStyle(Loud.ink)
        }
    }
}

func deepLink(for event: EventSnapshot) -> URL? {
    URL(string: "sleeps://event/\(event.id.uuidString)")
}

struct SmallView: View {
    let event: EventSnapshot

    var body: some View {
        VStack(spacing: 1) {
            LoudChip(icon: event.icon, size: 40)
            if event.days > 0 {
                Text("\(event.days)")
                    .font(Loud.heavy(event.days >= 100 ? 34 : 44))
                    .inkShadow()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text(event.days == 1 ? "SLEEP UNTIL" : "SLEEPS UNTIL")
                    .font(Loud.heavy(8))
                    .kerning(1.2)
            } else {
                Text("TODAY!")
                    .font(Loud.heavy(24))
                    .inkShadow(2)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .padding(.vertical, 4)
            }
            Text(event.title.uppercased())
                .font(Loud.heavy(11))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(deepLink(for: event))
    }
}

struct MediumView: View {
    let events: [EventSnapshot]

    var body: some View {
        VStack(spacing: 7) {
            ForEach(events) { event in
                Link(destination: deepLink(for: event) ?? URL(string: "sleeps://")!) {
                    row(for: event)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func row(for event: EventSnapshot) -> some View {
        HStack(spacing: 9) {
                    LoudChip(icon: event.icon, size: 30)
                    Text(event.title.uppercased())
                        .font(Loud.heavy(12))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer(minLength: 6)
                    if event.days > 0 {
                        Text("\(event.days)")
                            .font(Loud.heavy(20))
                            .foregroundStyle(.white)
                            .inkShadow(2)
                        Text(event.days == 1 ? "SLEEP" : "SLEEPS")
                            .font(Loud.heavy(8))
                            .kerning(1)
                            .foregroundStyle(.white.opacity(0.9))
                    } else {
                        Text("TODAY! 🎉")
                            .font(Loud.heavy(13))
                            .foregroundStyle(.white)
                    }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .loudBox(EventColor.named(event.colorName).color, radius: 13, shadow: 3)
    }
}
