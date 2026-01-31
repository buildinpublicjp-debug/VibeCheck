import Testing
import Foundation
@testable import VibeCheck

struct VibeCheckErrorTests {

    @Test func healthKitNotAvailableDescription() {
        let error = VibeCheckError.healthKitNotAvailable
        #expect(error.errorDescription?.contains("not available") == true)
    }

    @Test func healthKitAuthorizationDeniedDescription() {
        let error = VibeCheckError.healthKitAuthorizationDenied
        #expect(error.errorDescription?.contains("denied") == true)
    }

    @Test func healthKitErrorWrapsUnderlying() {
        let underlying = NSError(domain: "test", code: 42, userInfo: [NSLocalizedDescriptionKey: "test error"])
        let error = VibeCheckError.healthKitError(underlying: underlying)
        #expect(error.errorDescription?.contains("test error") == true)
    }

    @Test func obsidianErrorIncludesMessage() {
        let error = VibeCheckError.obsidianError(message: "vault not found")
        #expect(error.errorDescription?.contains("vault not found") == true)
    }

    @Test func claudeAPIErrorIncludesMessage() {
        let error = VibeCheckError.claudeAPIError(message: "rate limited")
        #expect(error.errorDescription?.contains("rate limited") == true)
    }

    @Test func swiftDataErrorWrapsUnderlying() {
        let underlying = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "save failed"])
        let error = VibeCheckError.swiftDataError(underlying: underlying)
        #expect(error.errorDescription?.contains("save failed") == true)
    }
}
