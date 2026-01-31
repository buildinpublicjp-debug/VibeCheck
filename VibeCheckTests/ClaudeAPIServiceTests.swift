import Testing
import Foundation
@testable import VibeCheck

struct ClaudeAPIServiceTests {

    // MARK: - Prompt Building

    @Test func buildPromptContainsNoteText() {
        let note = "# My Daily Note\n- Went for a run"
        let prompt = ClaudeAPIService.buildPrompt(for: note)

        #expect(prompt.contains(note))
    }

    @Test func buildPromptContainsAllCategories() {
        let prompt = ClaudeAPIService.buildPrompt(for: "test")

        #expect(prompt.contains("workout"))
        #expect(prompt.contains("reading"))
        #expect(prompt.contains("insight"))
        #expect(prompt.contains("work"))
        #expect(prompt.contains("food"))
        #expect(prompt.contains("health"))
    }

    @Test func buildPromptRequestsJSONOnly() {
        let prompt = ClaudeAPIService.buildPrompt(for: "test")

        #expect(prompt.contains("ONLY valid JSON"))
    }

    // MARK: - JSON Extraction

    @Test func extractJSONPassesThroughCleanJSON() {
        let json = #"{"categories":[{"category":"workout","content":"ran 5k"}]}"#
        let result = ClaudeAPIService.extractJSON(from: json)

        #expect(result == json)
    }

    @Test func extractJSONRemovesCodeFences() {
        let wrapped = """
        ```json
        {"categories":[{"category":"workout","content":"ran 5k"}]}
        ```
        """
        let result = ClaudeAPIService.extractJSON(from: wrapped)

        #expect(result == #"{"categories":[{"category":"workout","content":"ran 5k"}]}"#)
    }

    @Test func extractJSONRemovesGenericCodeFences() {
        let wrapped = """
        ```
        {"categories":[]}
        ```
        """
        let result = ClaudeAPIService.extractJSON(from: wrapped)

        #expect(result == #"{"categories":[]}"#)
    }

    @Test func extractJSONTrimsWhitespace() {
        let padded = "   {\"categories\":[]}   "
        let result = ClaudeAPIService.extractJSON(from: padded)

        #expect(result == #"{"categories":[]}"#)
    }

    // MARK: - Keychain Integration

    @Test func hasAPIKeyReturnsFalseWhenNoKey() {
        let service = ClaudeAPIService(keychainService: "com.vibecheck.test.\(UUID().uuidString)")

        #expect(!service.hasAPIKey)
    }
}
