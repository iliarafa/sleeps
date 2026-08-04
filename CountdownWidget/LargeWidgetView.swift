import WidgetKit
import SwiftUI
import CountdownKit

struct LargeWidgetView: View {
    let events: [EventSnapshot]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let hero = events.first {
                Link(destination: deepLink(for: hero) ?? URL(string: "sleeps://")!) {
                    HStack(spacing: 12) {
                        LoudChip(icon: hero.icon, size: 48)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(hero.title.uppercased())
                                .font(Loud.heavy(16))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                            if hero.days > 0 {
                                Text("\(hero.days)")
                                    .font(Loud.heavy(56))
                                    .foregroundStyle(.white)
                                    .inkShadow()
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                Text(hero.days == 1 ? "MORE SLEEP" : "MORE SLEEPS")
                                    .font(Loud.heavy(12))
                                    .foregroundStyle(.white.opacity(0.9))
                            } else {
                                Text("TODAY!")
                                    .font(Loud.heavy(40))
                                    .foregroundStyle(.white)
                                    .inkShadow(2)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .loudBox(EventColor.named(hero.colorName).color, radius: 16, shadow: 4)
                }
            }
            ForEach(events.dropFirst()) { event in
                Link(destination: deepLink(for: event) ?? URL(string: "sleeps://")!) {
                    HStack(spacing: 9) {
                        LoudChip(icon: event.icon, size: 28)
                        Text(event.title.uppercased())
                            .font(Loud.heavy(12))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Spacer()
                        Text(event.days > 0 ? "\(event.days)" : "TODAY!")
                            .font(Loud.heavy(18))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .loudBox(EventColor.named(event.colorName).color, radius: 13, shadow: 3)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
    }
}
