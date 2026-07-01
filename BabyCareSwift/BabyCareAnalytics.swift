import Foundation

struct AnalysisPoint: Identifiable {
    let id = UUID()
    var label: String
    var count: Int
    var totalAmount: Int
}

enum BabyCareAnalytics {
    static func points(entries: [CareEntry], category: CareCategory, range: AnalysisRange, now: Date = Date()) -> [AnalysisPoint] {
        let calendar = Calendar.current
        let filtered = entries.filter { $0.categoryId == category.id }

        switch range {
        case .day:
            let days = monthDays(containing: now, calendar: calendar)
            return days.map { day in
                let bucket = filtered.filter { calendar.isDate($0.date, inSameDayAs: day) }
                return AnalysisPoint(label: "\(calendar.component(.day, from: day))", count: bucket.count, totalAmount: bucket.compactMap(\.amount).reduce(0, +))
            }
        case .week:
            let weekDays = weekDays(containing: now, calendar: calendar)
            return weekDays.map { day in
                let bucket = filtered.filter { calendar.isDate($0.date, inSameDayAs: day) }
                return AnalysisPoint(label: weekdayLabel(for: day, calendar: calendar), count: bucket.count, totalAmount: bucket.compactMap(\.amount).reduce(0, +))
            }
        case .month:
            let months = yearMonths(containing: now, calendar: calendar)
            return months.map { month in
                let bucket = filtered.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) && calendar.isDate($0.date, equalTo: month, toGranularity: .year) }
                return AnalysisPoint(label: "\(calendar.component(.month, from: month))월", count: bucket.count, totalAmount: bucket.compactMap(\.amount).reduce(0, +))
            }
        }
    }

    static func averageText(points: [AnalysisPoint], unit: BabyCareUnit) -> String {
        guard !points.isEmpty else { return "평균 0\(unit.rawValue)" }
        if unit == .count {
            let average = Double(points.map(\.count).reduce(0, +)) / Double(points.count)
            return String(format: "평균 %.1f회", average)
        }

        let average = Double(points.map(\.totalAmount).reduce(0, +)) / Double(points.count)
        return String(format: "평균 %.0f%@", average, unit.rawValue)
    }

    private static func monthDays(containing date: Date, calendar: Calendar) -> [Date] {
        guard let interval = calendar.dateInterval(of: .month, for: date) else { return [date] }
        var days: [Date] = []
        var current = interval.start
        while current < interval.end {
            days.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return days
    }

    private static func weekDays(containing date: Date, calendar: Calendar) -> [Date] {
        let startOfDay = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: startOfDay)
        let daysSinceMonday = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysSinceMonday, to: startOfDay) else {
            return [date]
        }

        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: monday)
        }
    }

    private static func yearMonths(containing date: Date, calendar: Calendar) -> [Date] {
        guard let interval = calendar.dateInterval(of: .year, for: date) else { return [date] }
        var months: [Date] = []
        var current = interval.start
        while current < interval.end {
            months.append(current)
            guard let next = calendar.date(byAdding: .month, value: 1, to: current) else { break }
            current = next
        }
        return months
    }

    private static func weekdayLabel(for date: Date, calendar: Calendar) -> String {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let index = calendar.component(.weekday, from: date) - 1
        let mondayFirstIndex = (index + 6) % 7
        return symbols[mondayFirstIndex]
    }
}
