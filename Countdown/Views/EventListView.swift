import SwiftUI
import SwiftData
import WidgetKit
import CountdownKit

struct EventListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Query(sort: \CountdownEvent.date) private var events: [CountdownEvent]

    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var path = NavigationPath()
    @State private var pendingDelete: CountdownEvent?

    private var upcoming: [CountdownEvent] { events.filter { !$0.isPast } }
    private var past: [CountdownEvent] { events.filter(\.isPast).reversed() }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Loud.paper.ignoresSafeArea()
                if events.isEmpty {
                    emptyState
                } else {
                    eventList
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) { header }
            .sheet(isPresented: $showingAdd) {
                AddEditEventView(event: nil)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .navigationDestination(for: CountdownEvent.self) { event in
                EventDetailView(event: event)
            }
            .toolbar(.hidden, for: .navigationBar)
            .confirmationDialog(
                "Delete \u{201C}\(pendingDelete?.title ?? "")\u{201D}?",
                isPresented: Binding(
                    get: { pendingDelete != nil },
                    set: { if !$0 { pendingDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let event = pendingDelete {
                        deleteEvent(event, modelContext: modelContext)
                    }
                    pendingDelete = nil
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .onOpenURL { url in
            if url.scheme == "sleeps", url.host() == "import" {
                do {
                    let payload = try EventImport.payload(from: url)
                    let event = EventImport.makeEvent(from: payload)
                    modelContext.insert(event)
                    try? modelContext.save()
                    WidgetCenter.shared.reloadAllTimelines()
                    WatchSync.pushUpcoming(events: events + [event])
                    Task {
                        if event.notificationsEnabled {
                            await NotificationScheduler.requestAuthorizationIfNeeded()
                        }
                        await NotificationScheduler.rescheduleAll(events: events + [event])
                        await LiveActivityManager.sync(events: events + [event])
                    }
                    path = NavigationPath()
                    path.append(event)
                } catch {
                    // Ignore malformed imports.
                }
                return
            }

            // sleeps://event/<uuid> — used by widget taps
            guard url.scheme == "sleeps", url.host() == "event",
                  let id = UUID(uuidString: url.lastPathComponent),
                  let event = events.first(where: { $0.id == id })
            else { return }
            path = NavigationPath()
            path.append(event)
        }
        .task {
            _ = YearlyRepeat.advancePastEvents(in: modelContext)
            WatchSync.pushUpcoming(events: events)
            await NotificationScheduler.rescheduleAll(events: events)
            await LiveActivityManager.sync(events: events)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("SLEEPS")
                .font(Loud.heavy(30))
                .foregroundStyle(Loud.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 1)
                .loudBox(Loud.sun, radius: 0, shadow: 4)

            Spacer()

            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(Loud.ink)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(Loud.paper))
                    .overlay(Circle().strokeBorder(Loud.ink, lineWidth: 3))
                    .background(Circle().fill(Loud.ink).offset(x: 3, y: 3))
            }
            .accessibilityLabel("Settings")

            Button {
                showingAdd = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(Loud.ink)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(Loud.sun))
                    .overlay(Circle().strokeBorder(Loud.ink, lineWidth: 3))
                    .background(Circle().fill(Loud.ink).offset(x: 3, y: 3))
            }
            .accessibilityLabel("Add a countdown")
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 14)
        .background(Loud.paper)
    }

    /// First-run: sleeping-kid art above one clear way in.
    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Image("EmptyArt")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 330)
                .allowsHitTesting(false)

            Button {
                showingAdd = true
            } label: {
                Text("ADD YOUR FIRST COUNTDOWN")
                    .font(Loud.heavy(16))
                    .kerning(0.5)
                    .foregroundStyle(Loud.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 15)
                    .loudBox(Loud.sun)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add your first countdown")

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }

    private var eventList: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                ForEach(upcoming) { event in
                    NavigationLink(value: event) {
                        EventCardView(event: event)
                    }
                    .buttonStyle(.plain)
                    .contextMenu { deleteButton(for: event) }
                }
                if !past.isEmpty {
                    Text("ALREADY HAPPENED")
                        .font(Loud.heavy(14))
                        .foregroundStyle(Loud.ink.opacity(0.45))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 14)
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
            .padding(.horizontal, 18)
            .padding(.horizontal, sizeClass == .regular ? 48 : 0)
            .padding(.top, 4)
            .padding(.bottom, 30)
        }
    }

    private func deleteButton(for event: CountdownEvent) -> some View {
        Button(role: .destructive) {
            pendingDelete = event
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

struct EventCardView: View {
    let event: CountdownEvent

    private var days: Int { event.daysRemaining }

    var body: some View {
        HStack(spacing: 12) {
            LoudChip(icon: event.icon)

            VStack(alignment: .leading, spacing: 1) {
                Text(event.title.uppercased())
                    .font(Loud.heavy(16))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.leading)
                Text(event.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()).uppercased())
                    .font(Loud.demi(11))
                    .opacity(0.9)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 0) {
                Text(days == 0 ? "0" : "\(days)")
                    .font(Loud.heavy(days >= 100 ? 32 : 44))
                    .inkShadow()
                    .lineLimit(1)
                Text(days == 0 ? "TODAY!" : (days == 1 ? "SLEEP" : "SLEEPS"))
                    .font(Loud.heavy(9))
                    .kerning(1.4)
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity)
        .loudBox(EventColor.named(event.colorName).color)
    }
}
