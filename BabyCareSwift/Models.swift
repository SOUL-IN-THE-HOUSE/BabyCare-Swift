import Foundation

enum BabyCareUnit: String, Codable, CaseIterable, Identifiable {
    case milliliter = "ml"
    case gram = "g"
    case minute = "분"
    case count = "회"

    var id: String { rawValue }

    var step: Int {
        switch self {
        case .milliliter: 10
        case .gram: 5
        case .minute: 5
        case .count: 1
        }
    }

    var defaultAmount: Int {
        switch self {
        case .milliliter: 80
        case .gram: 40
        case .minute: 30
        case .count: 1
        }
    }

    var needsAmount: Bool {
        self != .count
    }
}

struct BabyProfile: Codable, Equatable {
    var name: String
    var birthDate: Date
}

struct CareCategory: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var symbolName: String
    var tintHex: String
    var unit: BabyCareUnit
    var isEnabled: Bool
    var isDefault: Bool

    static let defaults: [CareCategory] = [
        CareCategory(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, title: "모유", symbolName: "drop.fill", tintHex: "F08BA8", unit: .milliliter, isEnabled: true, isDefault: true),
        CareCategory(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, title: "분유", symbolName: "bottle.fill", tintHex: "D37B4A", unit: .milliliter, isEnabled: true, isDefault: true),
        CareCategory(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, title: "이유식", symbolName: "fork.knife", tintHex: "B38B2D", unit: .gram, isEnabled: true, isDefault: true),
        CareCategory(id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!, title: "수면", symbolName: "moon.zzz.fill", tintHex: "5E7DBA", unit: .minute, isEnabled: true, isDefault: true),
        CareCategory(id: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!, title: "기저귀", symbolName: "heart.text.square.fill", tintHex: "6D8896", unit: .count, isEnabled: false, isDefault: true),
        CareCategory(id: UUID(uuidString: "66666666-6666-6666-6666-666666666666")!, title: "목욕", symbolName: "shower.fill", tintHex: "4D9AA7", unit: .count, isEnabled: false, isDefault: true),
        CareCategory(id: UUID(uuidString: "77777777-7777-7777-7777-777777777777")!, title: "병원", symbolName: "cross.case.fill", tintHex: "B45F66", unit: .count, isEnabled: false, isDefault: true)
    ]
}

struct CareEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var categoryId: UUID
    var categoryTitle: String
    var symbolName: String
    var tintHex: String
    var unit: BabyCareUnit
    var amount: Int?
    var note: String
    var date: Date

    var amountText: String {
        guard let amount else { return "1회" }
        return "\(amount)\(unit.rawValue)"
    }
}

struct BabyCareBackup: Codable {
    var profile: BabyProfile?
    var categories: [CareCategory]
    var entries: [CareEntry]
}

struct CategorySummary: Identifiable {
    var id: UUID { category.id }
    var category: CareCategory
    var count: Int
    var totalAmount: Int
    var lastEntryDate: Date?
}

enum AnalysisRange: String, CaseIterable, Identifiable {
    case day = "일간"
    case week = "주간"
    case month = "월간"

    var id: String { rawValue }
}
