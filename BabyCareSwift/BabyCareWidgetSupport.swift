import Foundation

enum BabyCareAppGroup {
    static let identifier = "group.com.soulinmyhouse.babycare.swift"
    static let defaultsKey = "babyCareStore.v1"
}

enum BabyCareSharedStorage {
    static func loadBackup() -> BabyCareBackup? {
        if let backup = loadBackup(from: UserDefaults(suiteName: BabyCareAppGroup.identifier)) {
            return backup
        }
        return loadBackup(from: .standard)
    }

    static func saveBackup(_ backup: BabyCareBackup) {
        guard let data = try? encoder.encode(backup) else { return }
        UserDefaults.standard.set(data, forKey: BabyCareAppGroup.defaultsKey)
        UserDefaults(suiteName: BabyCareAppGroup.identifier)?.set(data, forKey: BabyCareAppGroup.defaultsKey)
    }

    private static func loadBackup(from defaults: UserDefaults?) -> BabyCareBackup? {
        guard let defaults,
              let data = defaults.data(forKey: BabyCareAppGroup.defaultsKey),
              let backup = try? decoder.decode(BabyCareBackup.self, from: data) else {
            return nil
        }
        return backup
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

struct WidgetFeedStat: Identifiable {
    var id: UUID
    var title: String
    var tintHex: String
    var count: Int
    var totalAmount: Int
    var unit: BabyCareUnit
    var lastDate: Date?

    var amountText: String {
        "\(totalAmount)\(unit.rawValue)"
    }
}

struct BabyCareWidgetSnapshot {
    var profileName: String
    var ddayText: String
    var totalFeedCount: Int
    var feedStats: [WidgetFeedStat]
    var lastFeedTitle: String?
    var lastFeedDate: Date?
    var updatedAt: Date

    static func make(now: Date = Date()) -> BabyCareWidgetSnapshot {
        let backup = BabyCareSharedStorage.loadBackup()
        let profile = backup?.profile
        let calendar = Calendar.current
        let feedEntries = (backup?.entries ?? []).filter { $0.unit == .milliliter || $0.unit == .gram }
        let todayFeedEntries = feedEntries.filter { calendar.isDate($0.date, inSameDayAs: now) }
        let stats = (backup?.categories ?? CareCategory.defaults)
            .filter { $0.isEnabled && ($0.unit == .milliliter || $0.unit == .gram) }
            .compactMap { category -> WidgetFeedStat? in
                let matched = todayFeedEntries.filter { $0.categoryId == category.id }
                guard !matched.isEmpty else { return nil }
                return WidgetFeedStat(
                    id: category.id,
                    title: category.title,
                    tintHex: category.tintHex,
                    count: matched.count,
                    totalAmount: matched.compactMap(\.amount).reduce(0, +),
                    unit: category.unit,
                    lastDate: matched.map(\.date).max()
                )
            }

        let lastFeed = feedEntries.max(by: { $0.date < $1.date })

        return BabyCareWidgetSnapshot(
            profileName: profile?.name ?? "아기",
            ddayText: profile.map { Self.ddayText(birthDate: $0.birthDate, now: now) } ?? "",
            totalFeedCount: todayFeedEntries.count,
            feedStats: stats.sorted { $0.lastDate ?? .distantPast > $1.lastDate ?? .distantPast },
            lastFeedTitle: lastFeed?.categoryTitle,
            lastFeedDate: lastFeed?.date,
            updatedAt: now
        )
    }

    var hasFeedData: Bool {
        totalFeedCount > 0 || lastFeedDate != nil
    }

    var summaryLine: String {
        guard totalFeedCount > 0 else { return "오늘 기록 없음" }
        return "오늘 \(totalFeedCount)회"
    }

    var statsLine: String {
        guard !feedStats.isEmpty else { return "수유 기록 없음" }

        let base = feedStats.prefix(2).map { "\($0.title) \($0.count)회 \($0.amountText)" }
        let remaining = max(0, feedStats.count - 2)
        if remaining > 0 {
            return base.joined(separator: " · ") + " · +\(remaining)"
        }
        return base.joined(separator: " · ")
    }

    var lastFeedLine: String {
        guard let lastFeedTitle, let lastFeedDate else { return "마지막 기록 없음" }
        return "\(lastFeedTitle) \(BabyCareFormatters.relativeTime(from: lastFeedDate, to: updatedAt))"
    }

    var inlineText: String {
        if totalFeedCount == 0 {
            return "수유 기록 없음"
        }

        if let lastFeedTitle, let lastFeedDate {
            return "\(summaryLine) · \(lastFeedTitle) \(BabyCareFormatters.relativeTime(from: lastFeedDate, to: updatedAt))"
        }

        return summaryLine
    }

    var circularText: String {
        if totalFeedCount == 0 {
            return "0"
        }
        return "\(totalFeedCount)"
    }

    private static func ddayText(birthDate: Date, now: Date) -> String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: birthDate)
        let end = calendar.startOfDay(for: now)
        let days = max(1, (calendar.dateComponents([.day], from: start, to: end).day ?? 0) + 1)
        return "D+\(days)"
    }
}
