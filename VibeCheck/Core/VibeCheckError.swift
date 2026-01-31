import Foundation

enum VibeCheckError: LocalizedError {
    case healthKitError(underlying: Error)
    case healthKitNotAvailable
    case healthKitAuthorizationDenied
    case obsidianError(message: String)
    case claudeAPIError(message: String)
    case swiftDataError(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .healthKitError(let underlying):
            "HealthKit error: \(underlying.localizedDescription)"
        case .healthKitNotAvailable:
            "HealthKit is not available on this device."
        case .healthKitAuthorizationDenied:
            "HealthKit authorization was denied. Please enable access in Settings."
        case .obsidianError(let message):
            "Obsidian error: \(message)"
        case .claudeAPIError(let message):
            "Claude API error: \(message)"
        case .swiftDataError(let underlying):
            "Data error: \(underlying.localizedDescription)"
        }
    }
}
