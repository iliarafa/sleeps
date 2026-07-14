import SwiftUI
import CountdownKit

struct EventDetailView: View {
    let event: CountdownEvent

    @State private var showingEdit = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [EventColor.named(event.colorName).color, EventColor.named(event.colorName).color.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer()

                Text(event.emoji)
                    .font(.system(size: 96))

                Text(event.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(CountdownText.headline(days: event.daysRemaining))
                    .font(.system(size: event.daysRemaining > 0 ? 140 : 64, weight: .black))
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .contentTransition(.numericText())

                Text(CountdownText.sleeps(days: event.daysRemaining))
                    .font(.title2.bold())
                    .opacity(0.9)

                Text(event.date, format: .dateTime.weekday(.wide).day().month(.wide).year())
                    .font(.headline)
                    .opacity(0.75)
                    .padding(.top, 8)

                Spacer()
                Spacer()
            }
            .foregroundStyle(.white)
            .padding()

            if event.isToday {
                ConfettiView()
            }
        }
        .fontDesign(.rounded)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showingEdit = true }
                    .foregroundStyle(.white)
                    .bold()
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditEventView(event: event)
        }
    }
}
