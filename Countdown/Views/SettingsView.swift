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
        ZStack {
            Loud.paper.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 9) {
                        Text("REMINDERS")
                            .font(Loud.heavy(13))
                            .kerning(1.2)
                            .foregroundStyle(Loud.ink.opacity(0.55))
                        DatePicker(
                            selection: $notificationTime,
                            displayedComponents: .hourAndMinute
                        ) {
                            Text("REMIND US AT")
                                .font(Loud.heavy(13))
                                .foregroundStyle(Loud.ink)
                        }
                        .tint(EventColor.blue.color)
                        .padding(14)
                        .loudBox(.white, radius: 14, shadow: 4)
                        .onChange(of: notificationTime) { _, newValue in
                            NotificationPrefs.time = newValue
                            let all = (try? modelContext.fetch(FetchDescriptor<CountdownEvent>())) ?? []
                            Task { await NotificationScheduler.rescheduleAll(events: all) }
                        }
                    }

                    VStack(alignment: .leading, spacing: 9) {
                        Text("FOR GROWN-UPS")
                            .font(Loud.heavy(13))
                            .kerning(1.2)
                            .foregroundStyle(Loud.ink.opacity(0.55))
                        Button {
                            gate = ParentalGate {
                                UIApplication.shared.open(Self.privacyPolicyURL)
                            }
                        } label: {
                            HStack {
                                Text("PRIVACY POLICY")
                                    .font(Loud.heavy(13))
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 13, weight: .heavy))
                            }
                            .foregroundStyle(Loud.ink)
                            .padding(14)
                            .loudBox(.white, radius: 14, shadow: 4)
                        }
                        .buttonStyle(.plain)
                    }

                    HStack {
                        Text("VERSION")
                            .font(Loud.heavy(13))
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .font(Loud.demi(13))
                    }
                    .foregroundStyle(Loud.ink)
                    .padding(14)
                    .loudBox(.white, radius: 14, shadow: 4)

                    Text("Made with ❤️ for kids who can't wait.")
                        .font(Loud.demi(12))
                        .foregroundStyle(Loud.ink.opacity(0.5))
                        .frame(maxWidth: .infinity)
                }
                .padding(20)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                Text("SETTINGS")
                    .font(Loud.heavy(15))
                    .foregroundStyle(Loud.ink)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("DONE")
                        .font(Loud.heavy(13))
                        .foregroundStyle(Loud.ink)
                        .padding(.horizontal, 16)
                        .frame(height: 38)
                        .background(Capsule().fill(Loud.sun))
                        .overlay(Capsule().strokeBorder(Loud.ink, lineWidth: 3))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Loud.paper)
        }
        .sheet(item: $gate) { gate in
            ParentalGateView(gate: gate)
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
        ZStack {
            Loud.paper.ignoresSafeArea()
            VStack(spacing: 18) {
                Text("ASK A GROWN-UP! 🧑‍🦱")
                    .font(Loud.heavy(20))
                Text("To open this link, solve:")
                    .font(Loud.demi(14))
                    .opacity(0.6)
                Text("\(gate.a) × \(gate.b) = ?")
                    .font(Loud.heavy(36))
                TextField("?", text: $answer)
                    .keyboardType(.numberPad)
                    .font(Loud.heavy(24))
                    .multilineTextAlignment(.center)
                    .frame(width: 110, height: 52)
                    .loudBox(.white, radius: 12, shadow: 4)
                if wrong {
                    Text("NOT QUITE — TRY AGAIN!")
                        .font(Loud.heavy(12))
                        .foregroundStyle(EventColor.red.color)
                }
                Button {
                    if Int(answer) == gate.a * gate.b {
                        dismiss()
                        gate.onPass()
                    } else {
                        wrong = true
                        answer = ""
                    }
                } label: {
                    Text("CONTINUE")
                        .font(Loud.heavy(15))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 11)
                        .loudBox(Loud.sun, radius: 14, shadow: 4)
                }
                .buttonStyle(.plain)
                Button("Cancel") { dismiss() }
                    .font(Loud.demi(13))
                    .foregroundStyle(Loud.ink.opacity(0.5))
            }
            .foregroundStyle(Loud.ink)
            .padding(32)
        }
        .presentationDetents([.medium])
    }
}
