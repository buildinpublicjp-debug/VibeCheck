import Foundation
import os

@Observable
final class ObsidianService: ObsidianServiceProtocol, @unchecked Sendable {

    private static let bookmarkKey = "obsidianVaultBookmark"
    private static let vaultNameKey = "obsidianVaultName"
    private static let dailyNotesFolderKey = "obsidianDailyNotesFolder"
    private static let defaultDailyNotesFolder = "Daily Notes"

    private let logger = Logger(subsystem: "com.vibecheck", category: "ObsidianService")
    private let defaults: UserDefaults

    var isVaultConnected: Bool {
        defaults.data(forKey: Self.bookmarkKey) != nil
    }

    var vaultName: String? {
        defaults.string(forKey: Self.vaultNameKey)
    }

    var dailyNotesFolder: String {
        get {
            defaults.string(forKey: Self.dailyNotesFolderKey) ?? Self.defaultDailyNotesFolder
        }
        set {
            defaults.set(newValue, forKey: Self.dailyNotesFolderKey)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func storeBookmark(for url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw VibeCheckError.obsidianError(message: "Failed to access security-scoped resource.")
        }
        defer { url.stopAccessingSecurityScopedResource() }

        let bookmarkData = try url.bookmarkData(
            options: .minimalBookmark,
            includingResourceValuesForKeys: nil,
            relativeTo: nil as URL?
        )
        defaults.set(bookmarkData, forKey: Self.bookmarkKey)
        defaults.set(url.lastPathComponent, forKey: Self.vaultNameKey)
        logger.info("Stored bookmark for vault: \(url.lastPathComponent)")
    }

    func resolveBookmark() throws -> URL {
        guard let data = defaults.data(forKey: Self.bookmarkKey) else {
            throw VibeCheckError.obsidianError(message: "No vault bookmark found.")
        }

        var isStale = false
        let url = try URL(
            resolvingBookmarkData: data,
            options: [],
            relativeTo: nil as URL?,
            bookmarkDataIsStale: &isStale
        )

        if isStale {
            logger.info("Bookmark is stale, re-saving.")
            let newData = try url.bookmarkData(
                options: .minimalBookmark,
                includingResourceValuesForKeys: nil,
                relativeTo: nil as URL?
            )
            defaults.set(newData, forKey: Self.bookmarkKey)
        }

        return url
    }

    func readDailyNote(for date: Date) throws -> String? {
        let vaultURL = try resolveBookmark()

        guard vaultURL.startAccessingSecurityScopedResource() else {
            throw VibeCheckError.obsidianError(message: "Failed to access vault.")
        }
        defer { vaultURL.stopAccessingSecurityScopedResource() }

        let filename = Self.filename(for: date)
        let fileURL = vaultURL
            .appendingPathComponent(dailyNotesFolder)
            .appendingPathComponent(filename)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            logger.info("Daily note not found: \(filename)")
            return nil
        }

        let content = try String(contentsOf: fileURL, encoding: .utf8)
        logger.info("Read daily note: \(filename) (\(content.count) chars)")
        return content
    }

    func clearVault() {
        defaults.removeObject(forKey: Self.bookmarkKey)
        defaults.removeObject(forKey: Self.vaultNameKey)
        logger.info("Vault disconnected.")
    }

    // MARK: - Helpers

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static func filename(for date: Date) -> String {
        dateFormatter.string(from: date) + ".md"
    }
}
