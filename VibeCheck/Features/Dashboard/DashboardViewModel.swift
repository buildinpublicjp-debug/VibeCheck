import Foundation
import SwiftData
import os

@Observable
final class DashboardViewModel {
    var isLoading = false
    var errorMessage: String?

    private let healthKitService: any HealthKitServiceProtocol
    private let logger = Logger(subsystem: "com.zdog.VibeCheck", category: "Dashboard")

    init(healthKitService: any HealthKitServiceProtocol) {
        self.healthKitService = healthKitService
    }

    func requestAccessAndLoad(modelContext: ModelContext) async {
        guard healthKitService.isAvailable else { return }
        do {
            try await healthKitService.requestAuthorization()
            await loadWeekData(modelContext: modelContext)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadWeekData(modelContext: ModelContext) async {
        isLoading = true
        defer { isLoading = false }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            await loadDay(date: date, modelContext: modelContext)
        }
    }

    private func loadDay(date: Date, modelContext: ModelContext) async {
        do {
            let data = try await healthKitService.fetchDailySummary(for: date)
            let startOfDay = Calendar.current.startOfDay(for: date)

            let descriptor = FetchDescriptor<DailySummary>(
                predicate: #Predicate { $0.date == startOfDay }
            )
            let existing = try modelContext.fetch(descriptor)

            let summary: DailySummary
            if let found = existing.first {
                summary = found
            } else {
                summary = DailySummary(date: date)
                modelContext.insert(summary)
            }

            summary.steps = data.steps
            summary.sleepHours = data.sleepHours
            summary.weightKg = data.weightKg
            summary.restingHeartRate = data.restingHeartRate
            summary.updatedAt = .now

            try modelContext.save()
        } catch {
            logger.error("Failed to load data for \(date): \(error.localizedDescription)")
        }
    }
}
