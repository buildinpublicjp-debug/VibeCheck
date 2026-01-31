import Testing
import Foundation
import SwiftData
@testable import VibeCheck

@MainActor
struct DashboardViewModelTests {

    private func makeModelContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DailySummary.self, configurations: config)
        return ModelContext(container)
    }

    // MARK: - Authorization

    @Test func requestAccessAndLoadCallsAuthorization() async throws {
        let mock = MockHealthKitService()
        let vm = DashboardViewModel(healthKitService: mock)
        let context = try makeModelContext()

        await vm.requestAccessAndLoad(modelContext: context)

        #expect(mock.authorizationRequested)
    }

    @Test func requestAccessSkipsWhenNotAvailable() async throws {
        let mock = MockHealthKitService()
        mock.isAvailable = false
        let vm = DashboardViewModel(healthKitService: mock)
        let context = try makeModelContext()

        await vm.requestAccessAndLoad(modelContext: context)

        #expect(!mock.authorizationRequested)
    }

    @Test func requestAccessSetsErrorOnAuthFailure() async throws {
        let mock = MockHealthKitService()
        mock.shouldThrowOnAuth = true
        let vm = DashboardViewModel(healthKitService: mock)
        let context = try makeModelContext()

        await vm.requestAccessAndLoad(modelContext: context)

        #expect(vm.errorMessage != nil)
    }

    // MARK: - Data Loading

    @Test func loadWeekDataFetches7Days() async throws {
        let mock = MockHealthKitService()
        let vm = DashboardViewModel(healthKitService: mock)
        let context = try makeModelContext()

        await vm.loadWeekData(modelContext: context)

        #expect(mock.fetchedDates.count == 7)
    }

    @Test func loadWeekDataSavesToSwiftData() async throws {
        let mock = MockHealthKitService()
        mock.mockData = HealthData(steps: 5000, sleepHours: 6.0, weightKg: 70.0, restingHeartRate: 60)
        let vm = DashboardViewModel(healthKitService: mock)
        let context = try makeModelContext()

        await vm.loadWeekData(modelContext: context)

        var descriptor = FetchDescriptor<DailySummary>()
        descriptor.sortBy = [SortDescriptor(\DailySummary.date, order: .reverse)]
        let summaries = try context.fetch(descriptor)

        #expect(summaries.count == 7)
        #expect(summaries.first?.steps == 5000)
        #expect(summaries.first?.sleepHours == 6.0)
        #expect(summaries.first?.weightKg == 70.0)
        #expect(summaries.first?.restingHeartRate == 60)
    }

    @Test func loadWeekDataUpdatesExistingRecord() async throws {
        let mock = MockHealthKitService()
        mock.mockData = HealthData(steps: 3000, sleepHours: 5.0, weightKg: nil, restingHeartRate: nil)
        let vm = DashboardViewModel(healthKitService: mock)
        let context = try makeModelContext()

        // First load
        await vm.loadWeekData(modelContext: context)

        // Update mock data
        mock.fetchedDates = []
        mock.mockData = HealthData(steps: 8000, sleepHours: 7.0, weightKg: 71.0, restingHeartRate: 58)

        // Second load
        await vm.loadWeekData(modelContext: context)

        var descriptor = FetchDescriptor<DailySummary>()
        descriptor.sortBy = [SortDescriptor(\DailySummary.date, order: .reverse)]
        let summaries = try context.fetch(descriptor)

        // Should still be 7 records, not 14
        #expect(summaries.count == 7)
        #expect(summaries.first?.steps == 8000)
    }

    @Test func loadWeekDataSetsIsLoadingCorrectly() async throws {
        let mock = MockHealthKitService()
        let vm = DashboardViewModel(healthKitService: mock)
        let context = try makeModelContext()

        #expect(!vm.isLoading)
        await vm.loadWeekData(modelContext: context)
        #expect(!vm.isLoading)
    }

    @Test func loadWeekDataHandlesFetchErrors() async throws {
        let mock = MockHealthKitService()
        mock.shouldThrowOnFetch = true
        let vm = DashboardViewModel(healthKitService: mock)
        let context = try makeModelContext()

        // Should not crash, errors are logged per-day
        await vm.loadWeekData(modelContext: context)

        let descriptor = FetchDescriptor<DailySummary>()
        let summaries = try context.fetch(descriptor)
        #expect(summaries.isEmpty)
    }
}
