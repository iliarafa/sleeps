import SwiftUI
import SwiftData
import WidgetKit
import CountdownKit

struct AddEditEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let event: CountdownEvent?

    @State private var title: String
    @State private var date: Date
    @State private var emoji: String
    @State private var colorName: String
    @State private var notificationsEnabled: Bool

    private static let emojis = [
        "🎉", "🎂", "🎄", "🎃", "🎁", "✈️", "🏖️", "⛱️",
        "⚽️", "🎢", "🏕️", "🎬", "🎠", "🚗", "🎓", "🎪",
        "🐶", "🐱", "🏊", "⛷️", "🚀", "⭐️", "❤️", "🏠",
    ]

    init(event: CountdownEvent?) {
        self.event = event
        _title = State(initialValue: event?.title ?? "")
        _date = State(initialValue: event?.date ?? Calendar.current.date(byAdding: .day, value: 7, to: .now)!)
        _emoji = State(initialValue: event?.emoji ?? "🎉")
        _colorName = State(initialValue: event?.colorName ?? "blue")
        _notificationsEnabled = State(initialValue: event?.notificationsEnabled ?? true)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("What are we waiting for?") {
                    TextField("Summer vacation, birthday…", text: $title)
                        .font(.title3)
                }

                Section("When is it?") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }

                Section("Pick a picture") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                        ForEach(Self.emojis, id: \.self) { candidate in
                            Text(candidate)
                                .font(.system(size: 28))
                                .frame(maxWidth: .infinity)
                                .padding(6)
                                .background(
                                    candidate == emoji ? AnyShapeStyle(.tint.opacity(0.25)) : AnyShapeStyle(.clear),
                                    in: RoundedRectangle(cornerRadius: 10)
                                )
                                .onTapGesture { emoji = candidate }
                        }
                    }
                }

                Section("Pick a color") {
                    HStack(spacing: 12) {
                        ForEach(EventColor.allCases) { option in
                            Circle()
                                .fill(option.color)
                                .frame(width: 36, height: 36)
                                .overlay {
                                    if option.rawValue == colorName {
                                        Image(systemName: "checkmark")
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                    }
                                }
                                .onTapGesture { colorName = option.rawValue }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                Section {
                    Toggle("Remind us as it gets close", isOn: $notificationsEnabled)
                }
            }
            .fontDesign(.rounded)
            .navigationTitle(event == nil ? "New Countdown" : "Edit Countdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .bold()
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        if let event {
            event.title = trimmed
            event.date = date
            event.emoji = emoji
            event.colorName = colorName
            event.notificationsEnabled = notificationsEnabled
        } else {
            let new = CountdownEvent(title: trimmed, date: date, emoji: emoji, colorName: colorName)
            new.notificationsEnabled = notificationsEnabled
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
