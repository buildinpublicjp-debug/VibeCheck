import Foundation

struct ClaudeParseResult: Sendable, Codable {
    let categories: [CategoryResult]

    struct CategoryResult: Sendable, Codable {
        let category: String
        let content: String
    }
}

protocol ClaudeAPIServiceProtocol: Sendable {
    var hasAPIKey: Bool { get }
    func saveAPIKey(_ key: String) throws
    func deleteAPIKey() throws
    func validateAPIKey() async throws -> Bool
    func parseDailyNote(_ text: String) async throws -> ClaudeParseResult
}
