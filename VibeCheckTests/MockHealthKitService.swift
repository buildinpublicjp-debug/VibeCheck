import Foundation
@testable import VibeCheck

final class MockHealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    var isAvailable: Bool = true
    var authorizationRequested = false
    var shouldThrowOnAuth = false
    var shouldThrowOnFetch = false
    var mockData = HealthData(steps: 10000, sleepHours: 7.5, weightKg: 72.0, restingHeartRate: 62)
    var fetchedDates: [Date] = []

    func requestAuthorization() async throws {
        authorizationRequested = true
        if shouldThrowOnAuth {
            throw VibeCheckError.healthKitAuthorizationDenied
        }
    }

    func fetchDailySummary(for date: Date) async throws -> HealthData {
        fetchedDates.append(date)
        if shouldThrowOnFetch {
            throw VibeCheckError.healthKitNotAvailable
        }
        return mockData
    }
}
