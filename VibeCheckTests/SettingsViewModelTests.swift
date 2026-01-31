import Testing
import Foundation
import SwiftData
@testable import VibeCheck

@MainActor
struct SettingsViewModelTests {

    private func makeModelContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: DailyNote.self, DailySummary.self,
            configurations: config
        )
        return ModelContext(container)
    }

    // MARK: - Vault Connection State

    @Test func initialStateIsDisconnected() {
        let mock = MockObsidianService()
        let vm = SettingsViewModel(obsidianService: mock)

        #expect(!vm.isVaultConnected)
        #expect(vm.vaultName == nil)
        #expect(vm.errorMessage == nil)
        #expect(vm.lastReadNote == nil)
    }

    @Test func dailyNotesFolderReflectsService() {
        let mock = MockObsidianService()
        mock.dailyNotesFolder = "Journal"
        let vm = SettingsViewModel(obsidianService: mock)

        #expect(vm.dailyNotesFolder == "Journal")
    }

    // MARK: - Connect Vault

    @Test func connectVaultStoresBookmark() {
        let mock = MockObsidianService()
        let vm = SettingsViewModel(obsidianService: mock)
        let url = URL(fileURLWithPath: "/tmp/MyVault")

        vm.connectVault(url: url)

        #expect(mock.storedURL == url)
        #expect(mock.isVaultConnected)
    }

    @Test func connectVaultSetsErrorOnFailure() {
        let mock = MockObsidianService()
        mock.shouldThrowOnStore = true
        let vm = SettingsViewModel(obsidianService: mock)
        let url = URL(fileURLWithPath: "/tmp/MyVault")

        vm.connectVault(url: url)

        #expect(vm.errorMessage != nil)
    }

    // MARK: - Disconnect Vault

    @Test func disconnectVaultClearsState() {
        let mock = MockObsidianService()
        mock.isVaultConnected = true
        mock.vaultName = "MyVault"
        let vm = SettingsViewModel(obsidianService: mock)

        vm.disconnectVault()

        #expect(mock.clearCalled)
        #expect(vm.lastReadNote == nil)
    }

    // MARK: - Read Today's Note

    @Test func readTodaysNoteSavesToSwiftData() throws {
        let mock = MockObsidianService()
        mock.isVaultConnected = true
        mock.mockNoteContent = "# Today\n- Did stuff"
        let vm = SettingsViewModel(obsidianService: mock)
        let context = try makeModelContext()

        vm.readTodaysNote(modelContext: context)

        #expect(vm.lastReadNote == "# Today\n- Did stuff")

        let descriptor = FetchDescriptor<DailyNote>()
        let notes = try context.fetch(descriptor)
        #expect(notes.count == 1)
        #expect(notes.first?.rawText == "# Today\n- Did stuff")
    }

    @Test func readTodaysNoteUpdatesExisting() throws {
        let mock = MockObsidianService()
        mock.isVaultConnected = true
        mock.mockNoteContent = "Version 1"
        let vm = SettingsViewModel(obsidianService: mock)
        let context = try makeModelContext()

        vm.readTodaysNote(modelContext: context)

        mock.mockNoteContent = "Version 2"
        vm.readTodaysNote(modelContext: context)

        let descriptor = FetchDescriptor<DailyNote>()
        let notes = try context.fetch(descriptor)
        #expect(notes.count == 1)
        #expect(notes.first?.rawText == "Version 2")
    }

    @Test func readTodaysNoteSetsErrorWhenNoteNotFound() throws {
        let mock = MockObsidianService()
        mock.isVaultConnected = true
        mock.mockNoteContent = nil
        let vm = SettingsViewModel(obsidianService: mock)
        let context = try makeModelContext()

        vm.readTodaysNote(modelContext: context)

        #expect(vm.errorMessage == "No daily note found for today.")
        #expect(vm.lastReadNote == nil)
    }

    @Test func readTodaysNoteSetsErrorOnReadFailure() throws {
        let mock = MockObsidianService()
        mock.isVaultConnected = true
        mock.shouldThrowOnRead = true
        let vm = SettingsViewModel(obsidianService: mock)
        let context = try makeModelContext()

        vm.readTodaysNote(modelContext: context)

        #expect(vm.errorMessage != nil)
    }
}
