import Foundation
import SwiftData
import os

@Observable
final class DayDetailViewModel {
    var dailySummary: DailySummary?
    var dailyNote: DailyNote?

    let date: Date

    private let logger = Logger(subsystem: "com.zdog.VibeCheck", category: "DayDetail")

    init(date: Date) {
        self.date = Calendar.current.startOfDay(for: date)
    }

    func loadData(modelContext: ModelContext) {
        let targetDate = date

        do {
            let summaryDescriptor = FetchDescriptor<DailySummary>(
                predicate: #Predicate { $0.date == targetDate }
            )
            dailySummary = try modelContext.fetch(summaryDescriptor).first

            let noteDescriptor = FetchDescriptor<DailyNote>(
                predicate: #Predicate { $0.date == targetDate }
            )
            dailyNote = try modelContext.fetch(noteDescriptor).first
        } catch {
            logger.error("Failed to load data for \(targetDate): \(error.localizedDescription)")
        }
    }
}
