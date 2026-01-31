import Testing
import Foundation
import SwiftData
@testable import VibeCheck

@MainActor
struct TimelineViewModelTests {

    private let calendar = Calendar.current

    private func makeModelContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: ParsedEntry.self, DailySummary.self, DailyNote.self,
            configurations: config
        )
        return ModelContext(container)
    }

    private func makeEntry(
        daysAgo: Int,
        category: EntryCategory,
        content: String = "Test content"
    ) -> ParsedEntry {
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: calendar.startOfDay(for: .now))!
        return ParsedEntry(date: date, category: category, content: content, dailyNoteDate: date)
    }

    // MARK: - Grouping

    @Test func groupedByWeekReturnsEmptyForNoEntries() {
        let vm = TimelineViewModel()
        let result = vm.groupedByWeek(entries: [], filterCategory: nil)
        #expect(result.isEmpty)
    }

    @Test func groupedByWeekGroupsEntriesInSameWeek() throws {
        let context = try makeModelContext()
        let vm = TimelineViewModel()

        // Create two entries on the same day
        let entry1 = makeEntry(daysAgo: 0, category: .workout)
        let entry2 = makeEntry(daysAgo: 0, category: .reading)
        context.insert(entry1)
        context.insert(entry2)

        let result = vm.groupedByWeek(entries: [entry1, entry2], filterCategory: nil)
        #expect(result.count == 1)
        #expect(result.first?.dayGroups.count == 1)
        #expect(result.first?.dayGroups.first?.entries.count == 2)
    }

    @Test func groupedByWeekSeparatesDifferentWeeks() throws {
        let context = try makeModelContext()
        let vm = TimelineViewModel()

        let entry1 = makeEntry(daysAgo: 0, category: .workout)
        let entry2 = makeEntry(daysAgo: 14, category: .reading)
        context.insert(entry1)
        context.insert(entry2)

        let result = vm.groupedByWeek(entries: [entry1, entry2], filterCategory: nil)
        #expect(result.count == 2)
    }

    @Test func groupedByWeekSortsMostRecentFirst() throws {
        let context = try makeModelContext()
        let vm = TimelineViewModel()

        let entry1 = makeEntry(daysAgo: 14, category: .workout)
        let entry2 = makeEntry(daysAgo: 0, category: .reading)
        context.insert(entry1)
        context.insert(entry2)

        let result = vm.groupedByWeek(entries: [entry1, entry2], filterCategory: nil)
        #expect(result.count == 2)
        #expect(result.first!.startDate > result.last!.startDate)
    }

    @Test func groupedByWeekSortsDaysWithinWeekDescending() throws {
        let context = try makeModelContext()
        let vm = TimelineViewModel()

        let entry1 = makeEntry(daysAgo: 1, category: .workout)
        let entry2 = makeEntry(daysAgo: 0, category: .reading)
        context.insert(entry1)
        context.insert(entry2)

        let result = vm.groupedByWeek(entries: [entry1, entry2], filterCategory: nil)

        // Both should be in the same week (1 day apart)
        // If they end up in different weeks due to week boundary, just verify ordering
        for week in result {
            if week.dayGroups.count > 1 {
                #expect(week.dayGroups.first!.date > week.dayGroups.last!.date)
            }
        }
    }

    // MARK: - Filtering

    @Test func filterByCategoryReturnsOnlyMatchingEntries() throws {
        let context = try makeModelContext()
        let vm = TimelineViewModel()

        let entry1 = makeEntry(daysAgo: 0, category: .workout)
        let entry2 = makeEntry(daysAgo: 0, category: .reading)
        context.insert(entry1)
        context.insert(entry2)

        let result = vm.groupedByWeek(entries: [entry1, entry2], filterCategory: .workout)
        let allEntries = result.flatMap { $0.dayGroups.flatMap { $0.entries } }
        #expect(allEntries.count == 1)
        #expect(allEntries.first?.category == .workout)
    }

    @Test func filterByCategoryNilReturnsAll() throws {
        let context = try makeModelContext()
        let vm = TimelineViewModel()

        let entry1 = makeEntry(daysAgo: 0, category: .workout)
        let entry2 = makeEntry(daysAgo: 0, category: .reading)
        let entry3 = makeEntry(daysAgo: 0, category: .food)
        context.insert(entry1)
        context.insert(entry2)
        context.insert(entry3)

        let result = vm.groupedByWeek(entries: [entry1, entry2, entry3], filterCategory: nil)
        let allEntries = result.flatMap { $0.dayGroups.flatMap { $0.entries } }
        #expect(allEntries.count == 3)
    }

    @Test func filterByCategoryReturnsEmptyIfNoMatch() throws {
        let context = try makeModelContext()
        let vm = TimelineViewModel()

        let entry1 = makeEntry(daysAgo: 0, category: .workout)
        context.insert(entry1)

        let result = vm.groupedByWeek(entries: [entry1], filterCategory: .reading)
        let allEntries = result.flatMap { $0.dayGroups.flatMap { $0.entries } }
        #expect(allEntries.isEmpty)
    }

    // MARK: - Edge Cases

    @Test func groupedByWeekHandlesMultipleEntriesSameDay() throws {
        let context = try makeModelContext()
        let vm = TimelineViewModel()

        let entry1 = makeEntry(daysAgo: 0, category: .workout, content: "Morning run")
        let entry2 = makeEntry(daysAgo: 0, category: .reading, content: "Read a book")
        let entry3 = makeEntry(daysAgo: 0, category: .food, content: "Had sushi")
        context.insert(entry1)
        context.insert(entry2)
        context.insert(entry3)

        let result = vm.groupedByWeek(entries: [entry1, entry2, entry3], filterCategory: nil)
        let dayGroup = result.first?.dayGroups.first
        #expect(dayGroup?.entries.count == 3)
    }

    @Test func groupedByWeekHandlesInvalidCategory() throws {
        let context = try makeModelContext()
        let vm = TimelineViewModel()

        // Create an entry with a valid category, then manually set invalid raw value
        let entry = makeEntry(daysAgo: 0, category: .workout)
        context.insert(entry)
        entry.categoryRawValue = "unknown_category"

        // Filtering by a specific category should exclude the invalid entry
        let result = vm.groupedByWeek(entries: [entry], filterCategory: .workout)
        let allEntries = result.flatMap { $0.dayGroups.flatMap { $0.entries } }
        #expect(allEntries.isEmpty)

        // No filter should include it
        let resultAll = vm.groupedByWeek(entries: [entry], filterCategory: nil)
        let allEntriesNoFilter = resultAll.flatMap { $0.dayGroups.flatMap { $0.entries } }
        #expect(allEntriesNoFilter.count == 1)
    }

    @Test func selectedCategoryInitiallyNil() {
        let vm = TimelineViewModel()
        #expect(vm.selectedCategory == nil)
    }
}
