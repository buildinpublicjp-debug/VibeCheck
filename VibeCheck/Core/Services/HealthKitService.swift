import Foundation
import HealthKit
import os

@Observable
final class HealthKitService: HealthKitServiceProtocol, Sendable {
    nonisolated static let shared = HealthKitService()

    private nonisolated let healthStore: HKHealthStore?
    private nonisolated let logger = Logger(subsystem: "com.zdog.VibeCheck", category: "HealthKit")

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    private nonisolated let readTypes: Set<HKObjectType> = {
        var types = Set<HKObjectType>()
        if let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            types.insert(stepCount)
        }
        if let bodyMass = HKQuantityType.quantityType(forIdentifier: .bodyMass) {
            types.insert(bodyMass)
        }
        if let heartRate = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) {
            types.insert(heartRate)
        }
        if let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepAnalysis)
        }
        return types
    }()

    nonisolated init() {
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
        } else {
            self.healthStore = nil
        }
    }

    // MARK: - Authorization

    func requestAuthorization() async throws {
        guard let healthStore else {
            throw VibeCheckError.healthKitNotAvailable
        }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
        } catch {
            logger.error("HealthKit authorization failed: \(error.localizedDescription)")
            throw VibeCheckError.healthKitError(underlying: error)
        }
    }

    // MARK: - Fetch Daily Summary

    func fetchDailySummary(for date: Date) async throws -> HealthData {
        guard let healthStore else {
            throw VibeCheckError.healthKitNotAvailable
        }

        async let steps = fetchSteps(for: date, store: healthStore)
        async let sleep = fetchSleepHours(for: date, store: healthStore)
        async let weight = fetchWeight(for: date, store: healthStore)
        async let heartRate = fetchRestingHeartRate(for: date, store: healthStore)

        return try await HealthData(
            steps: steps,
            sleepHours: sleep,
            weightKg: weight,
            restingHeartRate: heartRate
        )
    }

    // MARK: - Steps

    private func fetchSteps(for date: Date, store: HKHealthStore) async throws -> Int? {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return nil }

        let (start, end) = dayBounds(for: date)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(type: stepType, predicate: predicate),
            options: .cumulativeSum
        )

        let result = try await descriptor.result(for: store)
        guard let sum = result?.sumQuantity() else { return nil }
        return Int(sum.doubleValue(for: HKUnit.count()))
    }

    // MARK: - Sleep

    private func fetchSleepHours(for date: Date, store: HKHealthStore) async throws -> Double? {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }

        // Sleep data for a given "date" usually spans the previous night.
        // Look for sleep ending on this date.
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictEndDate)
        let sleepPredicate = HKCategoryValueSleepAnalysis.predicateForSamples(equalTo: [
            .asleepCore, .asleepDeep, .asleepREM
        ])
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, sleepPredicate])

        let descriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: sleepType, predicate: compoundPredicate)],
            sortDescriptors: [SortDescriptor(\.startDate)]
        )

        let samples = try await descriptor.result(for: store)
        guard !samples.isEmpty else { return nil }

        let totalSeconds = samples.reduce(0.0) { total, sample in
            total + sample.endDate.timeIntervalSince(sample.startDate)
        }

        return totalSeconds / 3600.0
    }

    // MARK: - Weight

    private func fetchWeight(for date: Date, store: HKHealthStore) async throws -> Double? {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return nil }

        let (start, end) = dayBounds(for: date)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: weightType, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)],
            limit: 1
        )

        let samples = try await descriptor.result(for: store)
        guard let latest = samples.first else { return nil }
        return latest.quantity.doubleValue(for: .gramUnit(with: .kilo))
    }

    // MARK: - Resting Heart Rate

    private func fetchRestingHeartRate(for date: Date, store: HKHealthStore) async throws -> Int? {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else { return nil }

        let (start, end) = dayBounds(for: date)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: hrType, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)],
            limit: 1
        )

        let samples = try await descriptor.result(for: store)
        guard let latest = samples.first else { return nil }
        return Int(latest.quantity.doubleValue(for: HKUnit(from: "count/min")))
    }

    // MARK: - Helpers

    private func dayBounds(for date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return (start, end)
    }
}
