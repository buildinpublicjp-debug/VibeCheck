import Foundation

struct HealthData: Sendable {
    let steps: Int?
    let sleepHours: Double?
    let weightKg: Double?
    let restingHeartRate: Int?
}

protocol HealthKitServiceProtocol: Sendable {
    var isAvailable: Bool { get }
    func requestAuthorization() async throws
    func fetchDailySummary(for date: Date) async throws -> HealthData
}
