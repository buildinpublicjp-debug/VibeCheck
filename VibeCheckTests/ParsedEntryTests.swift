import Testing
import Foundation
import SwiftData
@testable import VibeCheck

struct ParsedEntryTests {

    @Test func initNormalizesDateToStartOfDay() {
        var components = DateComponents()
        components.year = 2025
        components.month = 6
        components.day = 15
        components.hour = 14
        components.minute = 30
        let date = Calendar.current.date(from: components)!

        let entry = ParsedEntry(date: date, category: .workout, content: "Ran 5k", dailyNoteDate: date)
        let startOfDay = Calendar.current.startOfDay(for: date)

        #expect(entry.date == startOfDay)
        #expect(entry.dailyNoteDate == startOfDay)
    }

    @Test func initSetsAllFields() {
        let date = Calendar.current.startOfDay(for: .now)
        let entry = ParsedEntry(date: date, category: .reading, content: "Read Swift book", dailyNoteDate: date)

        #expect(entry.categoryRawValue == "reading")
        #expect(entry.content == "Read Swift book")
        #expect(entry.date == date)
        #expect(entry.dailyNoteDate == date)
    }

    @Test func initSetsTimestamps() {
        let before = Date.now
        let entry = ParsedEntry(date: .now, category: .food, content: "Lunch", dailyNoteDate: .now)
        let after = Date.now

        #expect(entry.createdAt >= before)
        #expect(entry.createdAt <= after)
        #expect(entry.updatedAt >= before)
        #expect(entry.updatedAt <= after)
    }

    @Test func categoryComputedPropertyReturnsEnum() {
        let entry = ParsedEntry(date: .now, category: .insight, content: "Idea", dailyNoteDate: .now)

        #expect(entry.category == .insight)
    }

    @Test func categoryReturnsNilForInvalidRawValue() {
        let entry = ParsedEntry(date: .now, category: .work, content: "Coded", dailyNoteDate: .now)
        entry.categoryRawValue = "invalid_category"

        #expect(entry.category == nil)
    }
}
