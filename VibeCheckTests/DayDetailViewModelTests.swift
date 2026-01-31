import Testing
import Foundation
import SwiftData
@testable import VibeCheck

@MainActor
struct DayDetailViewModelTests {

    private func makeModelContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: DailySummary.self, DailyNote.self, ParsedEntry.self,
            configurations: config
        )
        return ModelContext(container)
    }

    // MARK: - Data Loading

    @Test func loadDataFetchesSummaryForDate() throws {
        let context = try makeModelContext()
        let date = Calendar.current.startOfDay(for: .now)
        let summary = DailySummary(date: date, steps: 8000, sleepHours: 7.5)
        context.insert(summary)
        try context.save()

        let vm = DayDetailViewModel(date: date)
        vm.loadData(modelContext: context)

        #expect(vm.dailySummary != nil)
        #expect(vm.dailySummary?.steps == 8000)
        #expect(vm.dailySummary?.sleepHours == 7.5)
    }

    @Test func loadDataFetchesDailyNoteForDate() throws {
        let context = try makeModelContext()
        let date = Calendar.current.startOfDay(for: .now)
        let note = DailyNote(date: date, rawText: "# Today\nDid some work", filename: "2025-01-31.md")
        context.insert(note)
        try context.save()

        let vm = DayDetailViewModel(date: date)
        vm.loadData(modelContext: context)

        #expect(vm.dailyNote != nil)
        #expect(vm.dailyNote?.rawText == "# Today\nDid some work")
    }

    @Test func loadDataReturnsNilWhenNoData() throws {
        let context = try makeModelContext()
        let date = Calendar.current.startOfDay(for: .now)

        let vm = DayDetailViewModel(date: date)
        vm.loadData(modelContext: context)

        #expect(vm.dailySummary == nil)
        #expect(vm.dailyNote == nil)
    }

    @Test func initNormalizesDateToStartOfDay() {
        var components = DateComponents()
        components.year = 2025
        components.month = 6
        components.day = 15
        components.hour = 14
        components.minute = 30
        let dateWithTime = Calendar.current.date(from: components)!

        let vm = DayDetailViewModel(date: dateWithTime)

        let expected = Calendar.current.startOfDay(for: dateWithTime)
        #expect(vm.date == expected)
    }

    @Test func datePropertyMatchesInit() {
        let date = Calendar.current.startOfDay(for: .now)
        let vm = DayDetailViewModel(date: date)
        #expect(vm.date == date)
    }
}
