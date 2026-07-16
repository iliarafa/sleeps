import SwiftUI
import SwiftData
import WidgetKit
import CountdownKit

struct AddEditEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let event: CountdownEvent?
    var onDelete: (() -> Void)? = nil

    @State private var title: String
    @State private var date: Date
    @State private var icon: EventIcon
    @State private var colorName: String
    @State private var notificationsEnabled: Bool
    @State private var hasTime: Bool
    @State private var showingDeleteConfirm = false

    init(event: CountdownEvent?, onDelete: (() -> Void)? = nil) {
        self.event = event
        self.onDelete = onDelete
        _title = State(initialValue: event?.title ?? "")
        _date = State(initialValue: event?.date ?? Calendar.current.date(byAdding: .day, value: 7, to: .now)!)
        _icon = State(initialValue: event?.icon ?? .party)
        _colorName = State(initialValue: event?.colorName ?? "blue")
        _notificationsEnabled = State(initialValue: event?.notificationsEnabled ?? true)
        _hasTime = State(initialValue: event?.hasTime ?? false)
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            Loud.paper.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    section("WHAT ARE WE WAITING FOR?") {
                        TextField("Summer vacation, birthday…", text: $title)
                            .font(Loud.bold(18))
                            .foregroundStyle(Loud.ink)
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .loudBox(.white, radius: 14, shadow: 4)
                    }

                    section("WHEN IS IT?") {
                        VStack(spacing: 14) {
                            LoudCalendar(date: $date, tint: EventColor.named(colorName).color)
                                .padding(12)
                                .loudBox(.white, radius: 14, shadow: 4)

                            VStack(spacing: 14) {
                                Toggle(isOn: $hasTime.animation()) {
                                    Text("SET A TIME")
                                        .font(Loud.heavy(13))
                                        .foregroundStyle(Loud.ink)
                                }
                                .tint(EventColor.named(colorName).color)

                                if hasTime {
                                    DatePicker(selection: $date, displayedComponents: .hourAndMinute) {
                                        Text("WHAT TIME?")
                                            .font(Loud.heavy(13))
                                            .foregroundStyle(Loud.ink)
                                    }
                                    .tint(EventColor.named(colorName).color)
                                }
                            }
                            .padding(14)
                            .loudBox(.white, radius: 14, shadow: 4)
                        }
                    }

                    section("PICK A PICTURE") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                            ForEach(EventIcon.allCases) { candidate in
                                Button {
                                    icon = candidate
                                } label: {
                                    candidate.image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            Circle().fill(candidate == icon ? Loud.sun : .clear)
                                        )
                                        .overlay(
                                            Circle().strokeBorder(Loud.ink, lineWidth: candidate == icon ? 3 : 0)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .loudBox(.white, radius: 14, shadow: 4)
                    }

                    section("PICK A COLOR") {
                        HStack(spacing: 12) {
                            ForEach(EventColor.allCases) { option in
                                Button {
                                    colorName = option.rawValue
                                } label: {
                                    Circle()
                                        .fill(option.color)
                                        .frame(width: 38, height: 38)
                                        .overlay(Circle().strokeBorder(Loud.ink, lineWidth: 3))
                                        .overlay {
                                            if option.rawValue == colorName {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 15, weight: .heavy))
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .loudBox(.white, radius: 14, shadow: 4)
                    }

                    Toggle(isOn: $notificationsEnabled) {
                        Text("REMIND US AS IT GETS CLOSE")
                            .font(Loud.heavy(13))
                            .foregroundStyle(Loud.ink)
                    }
                    .tint(EventColor.green.color)
                    .padding(14)
                    .loudBox(.white, radius: 14, shadow: 4)

                    if event != nil {
                        Button {
                            showingDeleteConfirm = true
                        } label: {
                            Text("DELETE THIS COUNTDOWN")
                                .font(Loud.heavy(13))
                                .foregroundStyle(.white)
                                .padding(14)
                                .frame(maxWidth: .infinity)
                                .loudBox(EventColor.red.color, radius: 14, shadow: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 10)
                    }
                }
                .padding(20)
                .padding(.bottom, 30)
            }
        }
        .confirmationDialog(
            "Delete \u{201C}\(event?.title ?? "")\u{201D}?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let event {
                    deleteEvent(event, modelContext: modelContext)
                }
                onDelete?()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("CANCEL")
                        .font(Loud.heavy(13))
                        .foregroundStyle(Loud.ink)
                        .padding(.horizontal, 14)
                        .frame(height: 38)
                        .background(Capsule().fill(.white))
                        .overlay(Capsule().strokeBorder(Loud.ink, lineWidth: 3))
                }

                Spacer()

                Text(event == nil ? "NEW COUNTDOWN" : "EDIT")
                    .font(Loud.heavy(15))
                    .foregroundStyle(Loud.ink)

                Spacer()

                Button {
                    save()
                } label: {
                    Text("SAVE")
                        .font(Loud.heavy(13))
                        .foregroundStyle(Loud.ink)
                        .padding(.horizontal, 16)
                        .frame(height: 38)
                        .background(Capsule().fill(canSave ? Loud.sun : Loud.sun.opacity(0.35)))
                        .overlay(Capsule().strokeBorder(Loud.ink.opacity(canSave ? 1 : 0.35), lineWidth: 3))
                }
                .disabled(!canSave)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Loud.paper)
        }
    }

    private func section(_ label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(label)
                .font(Loud.heavy(13))
                .kerning(1.2)
                .foregroundStyle(Loud.ink.opacity(0.55))
            content()
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        if let event {
            event.title = trimmed
            event.date = date
            event.emoji = icon.rawValue
            event.colorName = colorName
            event.notificationsEnabled = notificationsEnabled
            event.hasTime = hasTime
        } else {
            let new = CountdownEvent(title: trimmed, date: date, emoji: icon.rawValue, colorName: colorName)
            new.notificationsEnabled = notificationsEnabled
            new.hasTime = hasTime
            modelContext.insert(new)
        }
        try? modelContext.save()

        let all = (try? modelContext.fetch(FetchDescriptor<CountdownEvent>())) ?? []
        Task {
            if notificationsEnabled {
                await NotificationScheduler.requestAuthorizationIfNeeded()
            }
            await NotificationScheduler.rescheduleAll(events: all)
        }
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
}
