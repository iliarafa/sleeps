import SwiftUI
import SwiftData
import WidgetKit
import CountdownKit

struct EventListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CountdownEvent.date) private var events: [CountdownEvent]

    @State private var showingAdd = false
    @State private var showingSettings = false

    private var upcoming: [CountdownEvent] { events.filter { !$0.isPast } }
    private var past: [CountdownEvent] { events.filter(\.isPast).reversed() }

    var body: some View {
        NavigationStack {
            Group {
                if events.isEmpty {
                    emptyState
                } else {
                    eventList
                }
            }
            .navigationTitle("Sleeps")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditEventView(event: nil)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .fontDesign(.rounded)
        .task {
            await NotificationScheduler.rescheduleAll(events: events)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🗓️")
                .font(.system(size: 72))
            Text("Nothing to count down yet!")
                .font(.title2.bold())
            Text("Add something exciting —\na birthday, a trip, a holiday…")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button {
                showingAdd = true
            } label: {
                Label("Add a countdown", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
        .padding()
    }

    private var eventList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(upcoming) { event in
                    NavigationLink(value: event) {
                        EventCardView(event: event)
                    }
                    .buttonStyle(.plain)
                    .contextMenu { deleteButton(for: event) }
                }
                if !past.isEmpty {
                    Text("Already happened")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 12)
                    ForEach(past) { event in
                        NavigationLink(value: event) {
                            EventCardView(event: event)
                                .opacity(0.55)
                        }
                        .buttonStyle(.plain)
                        .contextMenu { deleteButton(for: event) }
                    }
                }
            }
            .padding()
        }
        .navigationDestination(for: CountdownEvent.self) { event in
            EventDetailView(event: event)
        }
    }

    private func deleteButton(for event: CountdownEvent) -> some View {
        Button(role: .destructive) {
            modelContext.delete(event)
            let remaining = events.filter { $0 !== event }
            Task {
                await NotificationScheduler.rescheduleAll(events: remaining)
            }
            WidgetCenter.shared.reloadAllTimelines()
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

struct EventCardView: View {
    let event: CountdownEvent

    var body: some View {
        HStack(spacing: 14) {
            Text(event.emoji)
                .font(.system(size: 40))
                .frame(width: 62, height: 62)
                .background(.white.opacity(0.35), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.title3.bold())
                    .lineLimit(1)
                Text(event.date, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.subheadline)
                    .opacity(0.8)
            }

            Spacer()

            VStack(spacing: 0) {
                Text(CountdownText.headline(days: event.daysRemaining))
                    .font(event.daysRemaining > 0 ? .system(size: 40, weight: .heavy) : .headline.bold())
                    .minimumScaleFactor(0.5)
                if event.daysRemaining > 0 {
                    Text(event.daysRemaining == 1 ? "sleep" : "sleeps")
                        .font(.caption.bold())
                        .opacity(0.8)
                }
            }
            .frame(minWidth: 64)
        }
        .padding(16)
        .foregroundStyle(.white)
        .background(
            LinearGradient(
                colors: [EventColor.named(event.colorName).color, EventColor.named(event.colorName).color.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24)
        )
    }
}
