import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

@MainActor
final class BabyCareStore: ObservableObject {
    @Published var profile: BabyProfile? {
        didSet { save() }
    }

    @Published var categories: [CareCategory] {
        didSet { save() }
    }

    @Published var entries: [CareEntry] {
        didSet { save() }
    }

    private let defaultsKey = "babyCareStore.v1"
    private let calendar = Calendar.current

    var isConfigured: Bool {
        profile != nil
    }

    var enabledCategories: [CareCategory] {
        categories.filter(\.isEnabled)
    }

    init() {
        if let backup = BabyCareSharedStorage.loadBackup() {
            profile = backup.profile
            categories = Self.normalizedCategories(backup.categories.isEmpty ? CareCategory.defaults : backup.categories)
            entries = backup.entries.sorted { $0.date > $1.date }
        } else {
            profile = nil
            categories = Self.normalizedCategories(CareCategory.defaults)
            entries = []
        }
    }

    func configureBaby(name: String, birthDate: Date) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        profile = BabyProfile(name: trimmedName.isEmpty ? "아기" : trimmedName, birthDate: birthDate)
    }

    func babyAgeText(on date: Date = Date()) -> String {
        guard let profile else { return "" }
        let start = calendar.startOfDay(for: profile.birthDate)
        let end = calendar.startOfDay(for: date)
        let days = max(1, (calendar.dateComponents([.day], from: start, to: end).day ?? 0) + 1)
        return "\(profile.name) D+\(days)"
    }

    func babyDdayText(on date: Date = Date()) -> String {
        guard profile != nil else { return "" }
        let start = calendar.startOfDay(for: profile?.birthDate ?? date)
        let end = calendar.startOfDay(for: date)
        let days = max(1, (calendar.dateComponents([.day], from: start, to: end).day ?? 0) + 1)
        return "D+\(days)"
    }

    func addEntry(category: CareCategory, amount: Int?, note: String = "", date: Date = Date()) {
        let entry = CareEntry(
            id: UUID(),
            categoryId: category.id,
            categoryTitle: category.title,
            symbolName: category.symbolName,
            tintHex: category.tintHex,
            unit: category.unit,
            amount: amount,
            note: note,
            date: date
        )
        entries.insert(entry, at: 0)
        entries.sort { $0.date > $1.date }
    }

    func updateNote(for entry: CareEntry, note: String) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[index].note = note
    }

    func updateEntry(_ entry: CareEntry, amount: Int?, note: String, date: Date) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[index].amount = amount
        entries[index].note = note
        entries[index].date = date
        entries.sort { $0.date > $1.date }
    }

    func deleteEntries(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
    }

    func deleteEntry(_ entry: CareEntry) {
        entries.removeAll { $0.id == entry.id }
    }

    func setCategoryEnabled(_ category: CareCategory, enabled: Bool) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        categories[index].isEnabled = enabled
    }

    func addCustomCategory(title: String, unit: BabyCareUnit) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        categories.append(CareCategory(
            id: UUID(),
            title: trimmedTitle,
            symbolName: unit == .count ? "star.circle.fill" : "plus.circle.fill",
            tintHex: "7E6BA8",
            unit: unit,
            isEnabled: true,
            isDefault: false
        ))
    }

    func removeCategory(_ category: CareCategory) {
        if category.isDefault {
            setCategoryEnabled(category, enabled: false)
        } else {
            categories.removeAll { $0.id == category.id }
        }
    }

    func todayEntries(now: Date = Date()) -> [CareEntry] {
        entries.filter { calendar.isDate($0.date, inSameDayAs: now) }
    }

    func entries(on date: Date) -> [CareEntry] {
        entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func summaries(for date: Date = Date()) -> [CategorySummary] {
        enabledCategories.map { category in
            let matched = todayEntries(now: date).filter { $0.categoryId == category.id }
            return CategorySummary(
                category: category,
                count: matched.count,
                totalAmount: matched.compactMap(\.amount).reduce(0, +),
                lastEntryDate: matched.map(\.date).max()
            )
        }
    }

    func makeBackup() -> BabyCareBackup {
        BabyCareBackup(profile: profile, categories: categories, entries: entries)
    }

    func restore(from backup: BabyCareBackup) {
        profile = backup.profile
        categories = Self.normalizedCategories(backup.categories.isEmpty ? CareCategory.defaults : backup.categories)
        entries = backup.entries.sorted { $0.date > $1.date }
    }

    func resetAllData() {
        profile = nil
        categories = Self.normalizedCategories(CareCategory.defaults)
        entries = []
    }

    private func save() {
        BabyCareSharedStorage.saveBackup(makeBackup())
#if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
#endif
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

    private static func normalizedCategories(_ categories: [CareCategory]) -> [CareCategory] {
        let defaultsById = Dictionary(uniqueKeysWithValues: CareCategory.defaults.map { ($0.id, $0) })
        return categories.map { category in
            guard let defaultCategory = defaultsById[category.id] else { return category }
            return CareCategory(
                id: defaultCategory.id,
                title: defaultCategory.title,
                symbolName: defaultCategory.symbolName,
                tintHex: defaultCategory.tintHex,
                unit: defaultCategory.unit,
                isEnabled: category.isEnabled,
                isDefault: defaultCategory.isDefault
            )
        }
    }
}
