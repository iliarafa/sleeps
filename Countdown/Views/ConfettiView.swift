import SwiftUI
import CountdownKit

/// Hard-edged toy confetti: outlined squares and circles tumbling down,
/// matching the Big & Loud slab style. Canvas-only, no dependencies.
struct ConfettiView: View {
    var particleCount: Int = 36

    @State private var start = Date()

    private static let colors: [Color] = EventColor.allCases.map(\.color) + [Loud.sun]

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSince(start)
                for i in 0..<particleCount {
                    var rng = SeededRandom(seed: UInt64(i))
                    let x = rng.next() * size.width
                    let speed = 60 + rng.next() * 130
                    let phase = rng.next() * 2 * .pi
                    let offset = rng.next() * (size.height + 60)
                    let y = (t * speed + offset)
                        .truncatingRemainder(dividingBy: size.height + 60) - 30
                    let sway = sin(t * 1.4 + phase) * 22
                    let side = 8 + rng.next() * 8
                    let spin = Angle.radians(t * (0.8 + rng.next() * 1.6) + phase)
                    let color = Self.colors[i % Self.colors.count]
                    let isSquare = i % 2 == 0

                    context.drawLayer { layer in
                        layer.translateBy(x: x + sway, y: y)
                        layer.rotate(by: spin)
                        let rect = CGRect(x: -side / 2, y: -side / 2, width: side, height: side)
                        let path = isSquare ? Path(rect) : Path(ellipseIn: rect)
                        layer.fill(path, with: .color(color))
                        layer.stroke(path, with: .color(Loud.ink), lineWidth: 2)
                    }
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
