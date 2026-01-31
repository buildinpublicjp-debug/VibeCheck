import Testing
import Foundation
@testable import VibeCheck

struct DailySummaryTests {

    // MARK: - Initialization

    @Test func initNormalizesDateToStartOfDay() {
        let calendar = Calendar.current
        let afternoon = calendar.date(bySettingHour: 15, minute: 30, second: 0, of: .now)!
        let summary = DailySummary(date: afternoon)

        let expected = calendar.startOfDay(for: afternoon)
        #expect(summary.date == expected)
    }

    @Test func initSetsAllHealthFields() {
        let summary = DailySummary(
            date: .now,
            steps: 8500,
            sleepHours: 7.5,
            weightKg: 72.3,
            restingHeartRate: 62
        )

        #expect(summary.steps == 8500)
        #expect(summary.sleepHours == 7.5)
        #expect(summary.weightKg == 72.3)
        #expect(summary.restingHeartRate == 62)
    }

    @Test func initDefaultsHealthFieldsToNil() {
        let summary = DailySummary(date: .now)

        #expect(summary.steps == nil)
        #expect(summary.sleepHours == nil)
        #expect(summary.weightKg == nil)
        #expect(summary.restingHeartRate == nil)
    }

    @Test func initSetsTimestamps() {
        let before = Date.now
        let summary = DailySummary(date: .now)
        let after = Date.now

        #expect(summary.createdAt >= before)
        #expect(summary.createdAt <= after)
        #expect(summary.updatedAt >= before)
        #expect(summary.updatedAt <= after)
    }

    // MARK: - Formatted Output

    @Test func formattedStepsWithValue() {
        let summary = DailySummary(date: .now, steps: 12345)
        #expect(summary.formattedSteps == "12,345")
    }

    @Test func formattedStepsWithNil() {
        let summary = DailySummary(date: .now)
        #expect(summary.formattedSteps == nil)
    }

    @Test func formattedWeightWithValue() {
        let summary = DailySummary(date: .now, weightKg: 72.5)
        #expect(summary.formattedWeight == "72.5 kg")
    }

    @Test func formattedWeightWithNil() {
        let summary = DailySummary(date: .now)
        #expect(summary.formattedWeight == nil)
    }

    @Test func formattedSleepWithValue() {
        let summary = DailySummary(date: .now, sleepHours: 7.5)
        #expect(summary.formattedSleep == "7h 30m")
    }

    @Test func formattedSleepWithWholeHours() {
        let summary = DailySummary(date: .now, sleepHours: 8.0)
        #expect(summary.formattedSleep == "8h 0m")
    }

    @Test func formattedSleepWithNil() {
        let summary = DailySummary(date: .now)
        #expect(summary.formattedSleep == nil)
    }

    @Test func formattedHeartRateWithValue() {
        let summary = DailySummary(date: .now, restingHeartRate: 65)
        #expect(summary.formattedHeartRate == "65 bpm")
    }

    @Test func formattedHeartRateWithNil() {
        let summary = DailySummary(date: .now)
        #expect(summary.formattedHeartRate == nil)
    }

    @Test func formattedDateReturnsAbbreviated() {
        let summary = DailySummary(date: .now)
        let result = summary.formattedDate
        #expect(!result.isEmpty)
    }
}
