import SwiftUI

struct PastRecordView: View {
    @EnvironmentObject private var store: BabyCareStore
    @State private var selectedDate = Date()
    @State private var displayedMonth = Date()

    private let calendar = Self.makeCalendar()

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        header
                        monthCalendar
                        timeline
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("지난기록")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                displayedMonth = selectedDate
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text(BabyCareFormatters.fullDate.string(from: selectedDate))
                    .font(.headline.weight(.semibold))
                Spacer()
                Text("\(store.entries(on: selectedDate).count)개")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .glassCard()
        .contentShape(Rectangle())
    }

    private var monthCalendar: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Button {
                    shiftMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline.weight(.semibold))
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(BabyCareFormatters.monthYear.string(from: displayedMonth))
                    .font(.headline.weight(.semibold))

                Spacer()

                if !isCurrentMonth {
                    Button {
                        shiftMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.headline.weight(.semibold))
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear.frame(width: 34, height: 34)
                }
            }

            weekdayHeader

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(Array(calendarGridDays().enumerated()), id: \.offset) { _, day in
                    dayCell(day)
                }
            }
        }
        .padding(16)
        .glassCard()
        .contentShape(Rectangle())
        .highPriorityGesture(monthSwipeGesture)
    }

    private var weekdayHeader: some View {
        let symbols = mondayFirstWeekdaySymbols()
        return HStack(spacing: 0) {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayCell(_ day: Date?) -> some View {
        Group {
            if let day {
                let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
                let isToday = calendar.isDateInToday(day)
                let isFuture = calendar.startOfDay(for: day) > calendar.startOfDay(for: Date())
                let entries = store.entries(on: day)

                Button {
                    guard !isFuture else { return }
                    selectedDate = day
                    displayedMonth = day
                } label: {
                    VStack(spacing: 4) {
                        Text("\(calendar.component(.day, from: day))")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 26)

                        if !entries.isEmpty {
                            Circle()
                                .fill(isSelected ? Color.white : Color.accentColor)
                                .frame(width: 6, height: 6)
                        } else {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundStyle(isSelected ? Color.white : .primary)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(isSelected ? Color.accentColor : (isToday ? Color.accentColor.opacity(0.14) : Color.clear))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(isToday && !isSelected ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                            }
                    }
                }
                .buttonStyle(.plain)
                .disabled(isFuture)
                .opacity(isFuture ? 0.35 : 1)
            } else {
                Color.clear
                    .frame(height: 52)
            }
        }
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("타임라인")
                    .font(.headline)
                Spacer()
                Text(BabyCareFormatters.day.string(from: selectedDate))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            let entries = store.entries(on: selectedDate).sorted { $0.date > $1.date }

            if entries.isEmpty {
                ContentUnavailableView("선택한 날짜에 기록이 없습니다", systemImage: "clock", description: Text("다른 날짜를 선택해 보세요."))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 10) {
                    ForEach(entries) { entry in
                        TimelineRowView(entry: entry)
                    }
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    private func shiftMonth(by value: Int) {
        guard let nextMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        let todayMonthStart = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        if calendar.startOfDay(for: nextMonth) > calendar.startOfDay(for: todayMonthStart) {
            displayedMonth = todayMonthStart
        } else {
            displayedMonth = nextMonth
        }
        if !calendar.isDate(selectedDate, equalTo: nextMonth, toGranularity: .month) {
            let clampedSelected = min(nextMonth, Date())
            selectedDate = clampedSelected
        }
    }

    private var monthSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                guard abs(value.translation.width) > 40 else { return }

                if value.translation.width < 0 {
                    shiftMonth(by: 1)
                } else {
                    shiftMonth(by: -1)
                }
            }
    }

    private var isCurrentMonth: Bool {
        calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
    }

    private func calendarGridDays() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [selectedDate] }

        let startOfMonth = monthInterval.start
        let weekday = calendar.component(.weekday, from: startOfMonth)
        let daysBeforeStart = (weekday + 5) % 7
        var cells: [Date?] = Array(repeating: nil, count: daysBeforeStart)

        var current = startOfMonth
        while current < monthInterval.end {
            cells.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }

        while cells.count % 7 != 0 {
            cells.append(nil)
        }

        return cells
    }

    private func mondayFirstWeekdaySymbols() -> [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        return Array(symbols[1...]) + [symbols[0]]
    }

    private static func makeCalendar() -> Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }
}
