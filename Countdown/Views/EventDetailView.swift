import SwiftUI
import CountdownKit

struct EventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let event: CountdownEvent

    @State private var showingEdit = false

    private var days: Int { event.daysRemaining }

    var body: some View {
        ZStack {
            EventColor.named(event.colorName).color.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 8)

                // The banner card
                VStack(spacing: 2) {
                    Text(event.emoji)
                        .font(.system(size: 46))
                    Text(event.title.uppercased())
                        .font(Loud.heavy(20))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                    Text(event.date.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased())
                        .font(Loud.demi(12))
                        .opacity(0.65)
                }
                .foregroundStyle(Loud.ink)
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .frame(maxWidth: 280)
                .loudBox(Loud.paper, radius: 16)

                // The flashcard numeral
                Group {
                    if days > 0 {
                        Text("\(days)")
                            .font(Loud.heavy(days >= 100 ? 130 : 180))
                            .inkShadow(7)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .padding(.top, 10)
                        Text(days == 1 ? "MORE SLEEP" : "MORE SLEEPS")
                            .font(Loud.heavy(18))
                            .kerning(5)
                            .inkShadow(2)
                    } else if days == 0 {
                        Text("TODAY!")
                            .font(Loud.heavy(64))
                            .inkShadow(6)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .padding(.top, 26)
                        Text("HOORAY! 🎉")
                            .font(Loud.heavy(20))
                            .kerning(4)
                            .inkShadow(2)
                    } else {
                        Text(CountdownText.headline(days: days).uppercased())
                            .font(Loud.heavy(40))
                            .inkShadow(4)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .padding(.top, 30)
                    }
                }
                .foregroundStyle(.white)

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 24)

            if event.isToday {
                ConfettiView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(Loud.ink)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(Loud.paper))
                        .overlay(Circle().strokeBorder(Loud.ink, lineWidth: 3))
                }
                .accessibilityLabel("Back")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEdit = true
                } label: {
                    Text("EDIT")
                        .font(Loud.heavy(13))
                        .foregroundStyle(Loud.ink)
                        .padding(.horizontal, 14)
                        .frame(height: 38)
                        .background(Capsule().fill(Loud.paper))
                        .overlay(Capsule().strokeBorder(Loud.ink, lineWidth: 3))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingEdit) {
            AddEditEventView(event: event)
        }
    }
}
