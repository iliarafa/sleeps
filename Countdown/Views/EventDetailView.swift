import SwiftUI
import UIKit
import CountdownKit

struct EventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    let event: CountdownEvent

    @State private var showingEdit = false
    @State private var didPlayArrivalHaptic = false
    @State private var shareGate: ParentalGate?
    @State private var pendingShare: SharePayload?
    @State private var activeShare: SharePayload?

    private var isRegularWidth: Bool { sizeClass == .regular }
    private var arrivalConfettiCount: Int { isRegularWidth ? 54 : 36 }
    private var arrivalHeadlineSize: CGFloat { isRegularWidth ? 88 : 64 }

    private var dateSubtitle: String {
        let day = event.date.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased()
        guard event.hasTime else { return day }
        return day + " · " + event.date.formatted(date: .omitted, time: .shortened).uppercased()
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let phase = CountdownPhase.phase(eventDate: event.date, hasTime: event.hasTime, now: context.date)

            ZStack {
                EventColor.named(event.colorName).color.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: 8)

                    // The banner card
                    VStack(spacing: 2) {
                        event.icon.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                        Text(event.title.uppercased())
                            .font(Loud.heavy(20))
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.6)
                        Text(dateSubtitle)
                            .font(Loud.demi(12))
                            .multilineTextAlignment(.center)
                            .opacity(0.65)
                    }
                    .foregroundStyle(Loud.ink)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .frame(maxWidth: sizeClass == .regular ? 420 : 280)
                    .loudBox(Loud.paper, radius: 16)

                    // The flashcard numeral
                    numeral(for: phase)
                        .foregroundStyle(.white)

                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, 24)

                if phase == .arrived {
                    ConfettiView(particleCount: arrivalConfettiCount)
                        .onAppear { playArrivalHapticIfNeeded() }
                }
            }
            .onChange(of: phase) { _, newPhase in
                if newPhase != .arrived {
                    didPlayArrivalHaptic = false
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
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

                Spacer()

                // Share an HTTPS link (not bare sleeps://) so Messages / Mail / AirDrop
                // show up. The landing page redirects into sleeps://import… .
                // Kids Category: the share sheet is a door out of the app, so it
                // opens only after the parental gate — owner decision 2026-09-04.
                if let url = try? EventImport.publicShareURL(for: EventImport.makePayload(from: event)) {
                    Button {
                        shareGate = ParentalGate(prompt: "To share this countdown, solve:") {
                            pendingShare = SharePayload(
                                url: url,
                                subject: event.title,
                                message: EventImport.shareMessage(for: event)
                            )
                        }
                    } label: {
                        Text("SHARE")
                            .font(Loud.heavy(13))
                            .foregroundStyle(Loud.ink)
                            .padding(.horizontal, 14)
                            .frame(height: 38)
                            .background(Capsule().fill(Loud.paper))
                            .overlay(Capsule().strokeBorder(Loud.ink, lineWidth: 3))
                    }
                }

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
            .padding(.horizontal, 18)
            .padding(.vertical, 6)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingEdit) {
            AddEditEventView(event: event, onDelete: { dismiss() })
        }
        // The share sheet is presented from onDismiss, not from the gate's
        // onPass: a sheet set while the gate sheet is still animating out is
        // silently dropped by SwiftUI.
        .sheet(item: $shareGate, onDismiss: {
            if let share = pendingShare {
                pendingShare = nil
                activeShare = share
            }
        }) { gate in
            ParentalGateView(gate: gate)
        }
        .sheet(item: $activeShare) { share in
            ShareSheet(payload: share)
        }
    }

    @ViewBuilder
    private func numeral(for phase: CountdownPhase) -> some View {
        switch phase {
        case .sleeps(let days):
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

        case .ticking(let seconds):
            Text(CountdownText.clock(secondsRemaining: seconds))
                .font(Loud.heavy(64))
                .monospacedDigit()
                .inkShadow(6)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.top, 26)
            Text("TO GO")
                .font(Loud.heavy(18))
                .kerning(5)
                .inkShadow(2)

        case .arrived:
            Text(event.hasTime ? "IT'S TIME!" : "TODAY!")
                .font(Loud.heavy(arrivalHeadlineSize))
                .inkShadow(6)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.top, 26)
            Text("HOORAY! 🎉")
                .font(Loud.heavy(20))
                .kerning(4)
                .inkShadow(2)

        case .past(let days):
            Text(CountdownText.headline(days: days).uppercased())
                .font(Loud.heavy(40))
                .inkShadow(4)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.top, 30)
        }
    }

    private func playArrivalHapticIfNeeded() {
        guard !didPlayArrivalHaptic else { return }
        didPlayArrivalHaptic = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

struct SharePayload: Identifiable {
    let id = UUID()
    let url: URL
    let subject: String
    let message: String
}

/// ShareLink can't be presented programmatically, and SHARE must open only
/// after the parental gate — so the gate's pass presents UIKit's sheet.
private struct ShareSheet: UIViewControllerRepresentable {
    let payload: SharePayload

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: [MessageWithSubject(payload: payload), payload.url],
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

/// Carries the share message plus a Mail subject, matching what
/// ShareLink(item:subject:message:) used to provide.
private final class MessageWithSubject: NSObject, UIActivityItemSource {
    let payload: SharePayload
    init(payload: SharePayload) { self.payload = payload }

    func activityViewControllerPlaceholderItem(_ controller: UIActivityViewController) -> Any {
        payload.message
    }

    func activityViewController(_ controller: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        payload.message
    }

    func activityViewController(_ controller: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        payload.subject
    }
}
