import Foundation
@testable import VibeCheck

final class MockClaudeAPIService: ClaudeAPIServiceProtocol, @unchecked Sendable {
    var hasAPIKey: Bool = false

    var shouldThrowOnSave = false
    var shouldThrowOnDelete = false
    var shouldThrowOnValidate = false
    var shouldThrowOnParse = false
    var validateResult = true
    var mockParseResult = ClaudeParseResult(categories: [
        .init(category: "workout", content: "Ran 5k"),
        .init(category: "reading", content: "Read Swift book"),
    ])

    var savedAPIKey: String?
    var deleteCalled = false
    var validateCalled = false
    var parsedText: String?

    func saveAPIKey(_ key: String) throws {
        if shouldThrowOnSave {
            throw VibeCheckError.claudeAPIError(message: "Mock save error")
        }
        savedAPIKey = key
        hasAPIKey = true
    }

    func deleteAPIKey() throws {
        if shouldThrowOnDelete {
            throw VibeCheckError.claudeAPIError(message: "Mock delete error")
        }
        deleteCalled = true
        hasAPIKey = false
        savedAPIKey = nil
    }

    func validateAPIKey() async throws -> Bool {
        validateCalled = true
        if shouldThrowOnValidate {
            throw VibeCheckError.claudeAPIError(message: "Mock validate error")
        }
        return validateResult
    }

    func parseDailyNote(_ text: String) async throws -> ClaudeParseResult {
        parsedText = text
        if shouldThrowOnParse {
            throw VibeCheckError.claudeAPIError(message: "Mock parse error")
        }
        return mockParseResult
    }
}
