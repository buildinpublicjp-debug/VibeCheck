import Foundation
import os

@Observable
final class ClaudeAPIService: ClaudeAPIServiceProtocol, @unchecked Sendable {
    private static let apiKeyKeychainKey = "claude_api_key"
    private static let model = "claude-3-haiku-20240307"
    private static let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private static let anthropicVersion = "2023-06-01"

    private let keychainService: String
    private let urlSession: URLSession
    private let logger = Logger(subsystem: "com.vibecheck", category: "ClaudeAPIService")

    var hasAPIKey: Bool {
        (try? KeychainService.read(
            key: Self.apiKeyKeychainKey,
            service: keychainService
        )) != nil
    }

    init(keychainService: String = "com.vibecheck", urlSession: URLSession = .shared) {
        self.keychainService = keychainService
        self.urlSession = urlSession
    }

    func saveAPIKey(_ key: String) throws {
        try KeychainService.save(
            key: Self.apiKeyKeychainKey,
            value: key,
            service: keychainService
        )
        logger.info("API key saved to Keychain.")
    }

    func deleteAPIKey() throws {
        try KeychainService.delete(
            key: Self.apiKeyKeychainKey,
            service: keychainService
        )
        logger.info("API key deleted from Keychain.")
    }

    func validateAPIKey() async throws -> Bool {
        let apiKey = try readAPIKey()

        let body: [String: Any] = [
            "model": Self.model,
            "max_tokens": 16,
            "messages": [
                ["role": "user", "content": "Hi"]
            ],
        ]

        let (_, response) = try await performRequest(apiKey: apiKey, body: body)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VibeCheckError.claudeAPIError(message: "Invalid response.")
        }

        switch httpResponse.statusCode {
        case 200:
            return true
        case 401:
            throw VibeCheckError.claudeAPIError(message: "Invalid API key.")
        case 429:
            throw VibeCheckError.claudeAPIError(message: "Rate limited. Please try again later.")
        default:
            throw VibeCheckError.claudeAPIError(message: "Unexpected status: \(httpResponse.statusCode)")
        }
    }

    func parseDailyNote(_ text: String) async throws -> ClaudeParseResult {
        let apiKey = try readAPIKey()
        let prompt = Self.buildPrompt(for: text)

        let body: [String: Any] = [
            "model": Self.model,
            "max_tokens": 1024,
            "messages": [
                ["role": "user", "content": prompt]
            ],
        ]

        let (data, response) = try await performRequest(apiKey: apiKey, body: body)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VibeCheckError.claudeAPIError(message: "Invalid response.")
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw VibeCheckError.claudeAPIError(message: "Invalid API key.")
        case 429:
            throw VibeCheckError.claudeAPIError(message: "Rate limited. Please try again later.")
        default:
            throw VibeCheckError.claudeAPIError(message: "Unexpected status: \(httpResponse.statusCode)")
        }

        let responseBody = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let contentArray = responseBody?["content"] as? [[String: Any]],
              let firstBlock = contentArray.first,
              let text = firstBlock["text"] as? String else {
            throw VibeCheckError.claudeAPIError(message: "Could not extract text from response.")
        }

        let jsonString = Self.extractJSON(from: text)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw VibeCheckError.claudeAPIError(message: "Failed to convert extracted JSON to data.")
        }

        let result = try JSONDecoder().decode(ClaudeParseResult.self, from: jsonData)
        logger.info("Parsed daily note into \(result.categories.count) categories.")
        return result
    }

    // MARK: - Static Helpers (Testable)

    static func buildPrompt(for noteText: String) -> String {
        """
        以下のDaily Noteを分析し、内容を次のカテゴリに分類してください: \
        workout, reading, insight, work, food, health

        ノートに含まれるカテゴリのみを返してください。各カテゴリについて、\
        該当する内容を日本語で簡潔に要約してください。

        追加テキストやコードフェンスなしで、有効なJSONのみを返してください。以下の形式を使用:
        {"categories":[{"category":"workout","content":"要約をここに"}]}

        Daily Note:
        \(noteText)
        """
    }

    static func extractJSON(from text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove code fences if present
        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        } else if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }

        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }

        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Private

    private func readAPIKey() throws -> String {
        guard let key = try KeychainService.read(
            key: Self.apiKeyKeychainKey,
            service: keychainService
        ) else {
            throw VibeCheckError.claudeAPIError(message: "No API key configured.")
        }
        return key
    }

    private func performRequest(apiKey: String, body: [String: Any]) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: Self.apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(Self.anthropicVersion, forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        return try await urlSession.data(for: request)
    }
}
