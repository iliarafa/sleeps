import SwiftUI

/// Lightweight celebratory confetti: emoji falling in a Canvas, no dependencies.
struct ConfettiView: View {
    @State private var start = Date()

    private static let pieces = ["🎉", "🎊", "⭐️", "✨", "🎈"]

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSince(start)
                for i in 0..<50 {
                    var rng = SeededRandom(seed: UInt64(i))
                    let x = rng.next() * size.width
                    let speed = 60 + rng.next() * 140
                    let phase = rng.next() * 2 * .pi
                    let offset = rng.next() * (size.height + 60)
                    let y = (t * speed + offset)
                        .truncatingRemainder(dividingBy: size.height + 60) - 30
                    let sway = sin(t * 1.5 + phase) * 24
                    let fontSize = 14 + rng.next() * 16
                    context.draw(
                        Text(Self.pieces[i % Self.pieces.count]).font(.system(size: fontSize)),
                        at: CGPoint(x: x + sway, y: y)
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

/// Tiny deterministic RNG so confetti pieces keep stable trajectories across frames.
private struct SeededRandom {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed &* 6364136223846793005 &+ 1442695040888963407
    }

    mutating func next() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Double(state >> 11) / Double(UInt64.max >> 11)
    }
}
