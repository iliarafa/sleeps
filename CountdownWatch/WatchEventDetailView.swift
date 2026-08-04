import SwiftUI
import CountdownKit

/// One countdown, flashcard style: the numeral fills the screen.
struct WatchEventDetailView: View {
    let event: WatchEventSnapshot

    private var days: Int { event.daysRemaining }

    var body: some View {
        ZStack {
            event.color.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 5) {
                    event.icon.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text(event.title.uppercased())
                        .font(WatchLoud.heavy(13))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }

                numeral

                Text(subtitle)
                    .font(WatchLoud.demi(11))
                    .opacity(0.85)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var numeral: some View {
        if days > 0 {
            Text("\(days)")
                .font(WatchLoud.heavy(days >= 100 ? 54 : 68))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .shadow(color: Loud.ink, radius: 0, x: 3, y: 3)
            Text(days == 1 ? "MORE SLEEP" : "MORE SLEEPS")
                .font(WatchLoud.heavy(11))
                .kerning(2)
        } else if days == 0 {
            Text("TODAY!")
                .font(WatchLoud.heavy(40))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .shadow(color: Loud.ink, radius: 0, x: 2, y: 2)
            Text("HOORAY! 🎉")
                .font(WatchLoud.heavy(11))
                .kerning(1.5)
        } else {
            Text(CountdownText.headline(days: days).uppercased())
                .font(WatchLoud.heavy(24))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
        }
    }

    private var subtitle: String {
        let day = event.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()).uppercased()
        guard event.hasTime else { return day }
        return day + " · " + event.date.formatted(date: .omitted, time: .shortened).uppercased()
    }
}

#Preview {
    WatchEventDetailView(
        event: WatchEventSnapshot(
            id: UUID(),
            title: "Summer Camp",
            iconRaw: EventIcon.tent.rawValue,
            colorName: "green",
            date: .now.addingTimeInterval(86_400 * 3),
            hasTime: false
        )
    )
}
