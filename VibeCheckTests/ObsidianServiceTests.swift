import Testing
import Foundation
@testable import VibeCheck

struct ObsidianServiceTests {

    // MARK: - Filename Generation

    @Test func filenameForDateFormatsCorrectly() {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 2026, month: 1, day: 31)
        let date = calendar.date(from: components)!

        let filename = ObsidianService.filename(for: date)
        #expect(filename == "2026-01-31.md")
    }

    @Test func filenameForSingleDigitMonthPadsZero() {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 2026, month: 3, day: 5)
        let date = calendar.date(from: components)!

        let filename = ObsidianService.filename(for: date)
        #expect(filename == "2026-03-05.md")
    }

    @Test func filenameEndsWithMdExtension() {
        let filename = ObsidianService.filename(for: .now)
        #expect(filename.hasSuffix(".md"))
    }

    // MARK: - DateFormatter

    @Test func dateFormatterUsesPOSIXLocale() {
        let formatter = ObsidianService.dateFormatter
        #expect(formatter.locale.identifier == "en_US_POSIX")
    }

    @Test func dateFormatterUsesCorrectFormat() {
        let formatter = ObsidianService.dateFormatter
        #expect(formatter.dateFormat == "yyyy-MM-dd")
    }

    // MARK: - Initial State

    @Test func newServiceIsNotConnected() {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let service = ObsidianService(defaults: defaults)

        #expect(!service.isVaultConnected)
        #expect(service.vaultName == nil)
    }

    @Test func defaultDailyNotesFolderIsDailyNotes() {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let service = ObsidianService(defaults: defaults)

        #expect(service.dailyNotesFolder == "Daily Notes")
    }

    @Test func dailyNotesFolderCanBeChanged() {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let service = ObsidianService(defaults: defaults)

        service.dailyNotesFolder = "Journal"
        #expect(service.dailyNotesFolder == "Journal")
    }

    // MARK: - Bookmark Errors

    @Test func resolveBookmarkThrowsWhenNoBookmark() {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let service = ObsidianService(defaults: defaults)

        #expect(throws: VibeCheckError.self) {
            _ = try service.resolveBookmark()
        }
    }

    @Test func readDailyNoteThrowsWhenNoBookmark() {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let service = ObsidianService(defaults: defaults)

        #expect(throws: VibeCheckError.self) {
            _ = try service.readDailyNote(for: .now)
        }
    }

    // MARK: - Clear Vault

    @Test func clearVaultRemovesBookmarkData() {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        defaults.set(Data([0x01]), forKey: "obsidianVaultBookmark")
        defaults.set("MyVault", forKey: "obsidianVaultName")
        let service = ObsidianService(defaults: defaults)

        #expect(service.isVaultConnected)

        service.clearVault()

        #expect(!service.isVaultConnected)
        #expect(service.vaultName == nil)
    }
}
