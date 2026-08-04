import SwiftUI
import CountdownKit

/// The whole Watch app: a glance at the next few countdowns. Read-only by design —
/// adding and editing stay on the phone.
struct WatchEventListView: View {
    @EnvironmentObject private var store: WatchStore

    var body: some View {
        NavigationStack {
            Group {
                if store.events.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("SLEEPS")
            .navigationDestination(for: WatchEventSnapshot.self) { event in
                WatchEventDetailView(event: event)
            }
        }
    }

    private var list: some View {
        List {
            ForEach(store.events) { event in
                NavigationLink(value: event) {
                    WatchEventRow(event: event)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
            }
        }
        .listStyle(.carousel)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "iphone.gen3")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Loud.sun)
            Text("NO COUNTDOWNS YET")
                .font(WatchLoud.heavy(14))
                .multilineTextAlignment(.center)
            Text("Open Sleeps on your iPhone to add one.")
                .font(WatchLoud.demi(12))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
    }
}

struct WatchEventRow: View {
    let event: WatchEventSnapshot

    var body: some View {
        HStack(spacing: 8) {
            event.icon.image
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 0) {
                Text(event.title.uppercased())
                    .font(WatchLoud.heavy(13))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                Text(event.date.formatted(.dateTime.month(.abbreviated).day()).uppercased())
                    .font(WatchLoud.demi(10))
                    .opacity(0.85)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: -2) {
                Text(event.dayLabel)
                    .font(WatchLoud.heavy(26))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(sleepsCaption(days: event.daysRemaining))
                    .font(WatchLoud.heavy(8))
                    .kerning(0.8)
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(event.color)
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Loud.ink, lineWidth: 2))
        )
    }
}

#Preview {
    WatchEventRow(
        event: WatchEventSnapshot(
            id: UUID(),
            title: "Trip to Greece",
            iconRaw: EventIcon.plane.rawValue,
            colorName: "blue",
            date: .now.addingTimeInterval(86_400 * 12),
            hasTime: false
        )
    )
}
