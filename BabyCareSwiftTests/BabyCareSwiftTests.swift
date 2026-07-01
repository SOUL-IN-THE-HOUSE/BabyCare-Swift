import Foundation
import Testing
@testable import BabyCareSwift

struct BabyCareSwiftTests {
    @Test func babyAgeStartsAtDayOne() async throws {
        let store = await BabyCareStore()
        let birthDate = Date(timeIntervalSince1970: 0)

        await store.configureBaby(name: "하민", birthDate: birthDate)

        let text = await store.babyAgeText(on: birthDate)
        #expect(text == "하민 D+1")
    }

    @Test func summariesIncludeTodayTotals() async throws {
        let store = await BabyCareStore()
        await store.resetAllData()
        let formula = CareCategory.defaults[1]

        await store.setCategoryEnabled(formula, enabled: true)
        await store.addEntry(category: formula, amount: 120, date: Date())
        await store.addEntry(category: formula, amount: 80, date: Date())

        let summary = await store.summaries().first { $0.category.id == formula.id }

        #expect(summary?.count == 2)
        #expect(summary?.totalAmount == 200)
    }
}
