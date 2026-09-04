import SwiftUI
import CountdownKit

/// Kids Category requirement: doors out of the app open only after an adult
/// passes a gate. Guards the Settings "for grown-ups" links and the detail
/// screen's SHARE button (both routes out to Messages / Mail / Safari).
struct ParentalGate: Identifiable {
    let id = UUID()
    let a = Int.random(in: 6...9)
    let b = Int.random(in: 6...9)
    var prompt = "To open this link, solve:"
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
                Text(gate.prompt)
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
