import SwiftUI
import SwiftData
import CountdownKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var notificationTime = NotificationPrefs.time
    @State private var gate: ParentalGate?

    private static let privacyPolicyURL = URL(string: "https://csrllc.net/sleeps/privacy")!

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminders") {
                    DatePicker(
                        "Remind us at",
                        selection: $notificationTime,
                        displayedComponents: .hourAndMinute
                    )
                    .onChange(of: notificationTime) { _, newValue in
                        NotificationPrefs.time = newValue
                        let all = (try? modelContext.fetch(FetchDescriptor<CountdownEvent>())) ?? []
                        Task { await NotificationScheduler.rescheduleAll(events: all) }
                    }
                }

                Section("For grown-ups") {
                    Button("Privacy Policy") {
                        gate = ParentalGate {
                            UIApplication.shared.open(Self.privacyPolicyURL)
                        }
                    }
                }

                Section {
                    LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                } footer: {
                    Text("Made with ❤️ for kids who can't wait.")
                }
            }
            .fontDesign(.rounded)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(item: $gate) { gate in
                ParentalGateView(gate: gate)
            }
        }
    }
}

/// Kids Category requirement: external links open only after an adult passes a gate.
struct ParentalGate: Identifiable {
    let id = UUID()
    let a = Int.random(in: 6...9)
    let b = Int.random(in: 6...9)
    let onPass: () -> Void
}

struct ParentalGateView: View {
    @Environment(\.dismiss) private var dismiss
    let gate: ParentalGate

    @State private var answer = ""
    @State private var wrong = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Ask a grown-up! 🧑‍🦱")
                .font(.title2.bold())
            Text("To open this link, solve:")
                .foregroundStyle(.secondary)
            Text("\(gate.a) × \(gate.b) = ?")
                .font(.largeTitle.bold())
            TextField("Answer", text: $answer)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 120)
                .multilineTextAlignment(.center)
            if wrong {
                Text("Not quite — try again!")
                    .foregroundStyle(.red)
            }
            Button("Continue") {
                if Int(answer) == gate.a * gate.b {
                    dismiss()
                    gate.onPass()
                } else {
                    wrong = true
                    answer = ""
                }
            }
            .buttonStyle(.borderedProminent)
            Button("Cancel") { dismiss() }
                .foregroundStyle(.secondary)
        }
        .fontDesign(.rounded)
        .padding(32)
        .presentationDetents([.medium])
    }
}
