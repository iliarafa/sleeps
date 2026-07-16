import SwiftUI
import CountdownKit

/// A month-grid date picker drawn in the app's own "Big & Loud" style, so the
/// calendar matches AvenirNext everywhere else (the system graphical DatePicker
/// can't be re-fonted). Selecting a day preserves any time already on `date`.
struct LoudCalendar: View {
    @Binding var date: Date
    var tint: Color

    @State private var visibleMonth: Date

    private let calendar = Calendar.current

    init(date: Binding<Date>, tint: Color) {
        _date = date
        self.tint = tint
        let start = Calendar.current.dateInterval(of: .month, for: date.wrappedValue)?.start
            ?? date.wrappedValue
        _visibleMonth = State(initialValue: start)
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let shift = calendar.firstWeekday - 1
        return (0..<7).map { symbols[($0 + shift) % 7].uppercased() }
    }

    var body: some View {
        VStack(spacing: 10) {
            header
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(Loud.demi(11))
                        .foregroundStyle(Loud.ink.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
                ForEach(Array(CalendarGrid.cells(monthOf: visibleMonth, calendar: calendar).enumerated()), id: \.offset) { _, cell in
                    dayCell(cell)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text(visibleMonth.formatted(.dateTime.month(.wide).year()))
                .font(Loud.heavy(18))
                .foregroundStyle(Loud.ink)

            Spacer()

            HStack(spacing: 18) {
                monthButton(systemName: "chevron.left", by: -1, label: "Previous month")
                monthButton(systemName: "chevron.right", by: 1, label: "Next month")
            }
        }
    }

    private func monthButton(systemName: String, by value: Int, label: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                if let shifted = calendar.date(byAdding: .month, value: value, to: visibleMonth) {
                    visibleMonth = shifted
                }
            }
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    @ViewBuilder
    private func dayCell(_ cell: Date?) -> some View {
        if let cell {
            let day = calendar.component(.day, from: cell)
            let isSelected = calendar.isDate(cell, inSameDayAs: date)
            let isToday = calendar.isDateInToday(cell)

            Button {
                date = CalendarGrid.combine(day: cell, timeOf: date, calendar: calendar)
            } label: {
                Text("\(day)")
                    .font(Loud.heavy(17))
                    .foregroundStyle(isSelected ? .white : (isToday ? tint : Loud.ink))
                    .frame(width: 34, height: 34)
                    .background {
                        if isSelected {
                            Circle().fill(tint)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(cell.formatted(.dateTime.weekday(.wide).month(.wide).day()))
            .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
        } else {
            Color.clear.frame(minHeight: 40)
        }
    }
}
