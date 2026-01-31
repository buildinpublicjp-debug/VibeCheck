import Foundation
import SwiftData

@Model
final class DailySummary {
    #Unique<DailySummary>([\.date])

    var date: Date
    var steps: Int?
    var sleepHours: Double?
    var weightKg: Double?
    var restingHeartRate: Int?

    var createdAt: Date
    var updatedAt: Date

    init(
        date: Date,
        steps: Int? = nil,
        sleepHours: Double? = nil,
        weightKg: Double? = nil,
        restingHeartRate: Int? = nil
    ) {
        let calendar = Calendar.current
        self.date = calendar.startOfDay(for: date)
        self.steps = steps
        self.sleepHours = sleepHours
        self.weightKg = weightKg
        self.restingHeartRate = restingHeartRate
        self.createdAt = .now
        self.updatedAt = .now
    }

    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    var formattedWeight: String? {
        guard let weightKg else { return nil }
        return String(format: "%.1f kg", weightKg)
    }

    var formattedSleep: String? {
        guard let sleepHours else { return nil }
        let hours = Int(sleepHours)
        let minutes = Int((sleepHours - Double(hours)) * 60)
        return "\(hours)h \(minutes)m"
    }

    var formattedSteps: String? {
        guard let steps else { return nil }
        return steps.formatted()
    }

    var formattedHeartRate: String? {
        guard let restingHeartRate else { return nil }
        return "\(restingHeartRate) bpm"
    }
}
