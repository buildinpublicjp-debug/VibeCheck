import Foundation
@testable import VibeCheck

final class MockObsidianService: ObsidianServiceProtocol, @unchecked Sendable {
    var isVaultConnected: Bool = false
    var vaultName: String? = nil
    var dailyNotesFolder: String = "Daily Notes"

    var storedURL: URL?
    var shouldThrowOnStore = false
    var shouldThrowOnResolve = false
    var shouldThrowOnRead = false
    var mockNoteContent: String? = "# Mock Note"
    var readDates: [Date] = []
    var clearCalled = false

    func storeBookmark(for url: URL) throws {
        if shouldThrowOnStore {
            throw VibeCheckError.obsidianError(message: "Mock store error")
        }
        storedURL = url
        isVaultConnected = true
        vaultName = url.lastPathComponent
    }

    func resolveBookmark() throws -> URL {
        if shouldThrowOnResolve {
            throw VibeCheckError.obsidianError(message: "Mock resolve error")
        }
        guard let url = storedURL else {
            throw VibeCheckError.obsidianError(message: "No vault bookmark found.")
        }
        return url
    }

    func readDailyNote(for date: Date) throws -> String? {
        readDates.append(date)
        if shouldThrowOnRead {
            throw VibeCheckError.obsidianError(message: "Mock read error")
        }
        return mockNoteContent
    }

    func clearVault() {
        clearCalled = true
        isVaultConnected = false
        vaultName = nil
        storedURL = nil
    }
}
