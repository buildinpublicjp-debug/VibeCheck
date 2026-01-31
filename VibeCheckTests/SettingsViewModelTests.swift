import Testing
import Foundation
import SwiftData
@testable import VibeCheck

@MainActor
struct SettingsViewModelTests {

    private func makeModelContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: DailyNote.self, DailySummary.self, ParsedEntry.self,
            configurations: config
        )
        return ModelContext(container)
    }

    private func makeVM(
        obsidian: MockObsidianService = MockObsidianService(),
        claude: MockClaudeAPIService = MockClaudeAPIService()
    ) -> (SettingsViewModel, MockObsidianService, MockClaudeAPIService) {
        let vm = SettingsViewModel(obsidianService: obsidian, claudeAPIService: claude)
        return (vm, obsidian, claude)
    }

    // MARK: - Vault Connection State

    @Test func initialStateIsDisconnected() {
        let (vm, _, _) = makeVM()

        #expect(!vm.isVaultConnected)
        #expect(vm.vaultName == nil)
        #expect(vm.errorMessage == nil)
        #expect(vm.lastReadNote == nil)
    }

    @Test func dailyNotesFolderReflectsService() {
        let obsidian = MockObsidianService()
        obsidian.dailyNotesFolder = "Journal"
        let (vm, _, _) = makeVM(obsidian: obsidian)

        #expect(vm.dailyNotesFolder == "Journal")
    }

    // MARK: - Connect Vault

    @Test func connectVaultStoresBookmark() {
        let (vm, obsidian, _) = makeVM()
        let url = URL(fileURLWithPath: "/tmp/MyVault")

        vm.connectVault(url: url)

        #expect(obsidian.storedURL == url)
        #expect(obsidian.isVaultConnected)
    }

    @Test func connectVaultSetsErrorOnFailure() {
        let obsidian = MockObsidianService()
        obsidian.shouldThrowOnStore = true
        let (vm, _, _) = makeVM(obsidian: obsidian)
        let url = URL(fileURLWithPath: "/tmp/MyVault")

        vm.connectVault(url: url)

        #expect(vm.errorMessage != nil)
    }

    // MARK: - Disconnect Vault

    @Test func disconnectVaultClearsState() {
        let obsidian = MockObsidianService()
        obsidian.isVaultConnected = true
        obsidian.vaultName = "MyVault"
        let (vm, _, _) = makeVM(obsidian: obsidian)

        vm.disconnectVault()

        #expect(obsidian.clearCalled)
        #expect(vm.lastReadNote == nil)
    }

    // MARK: - Read Today's Note

    @Test func readTodaysNoteSavesToSwiftData() throws {
        let obsidian = MockObsidianService()
        obsidian.isVaultConnected = true
        obsidian.mockNoteContent = "# Today\n- Did stuff"
        let (vm, _, _) = makeVM(obsidian: obsidian)
        let context = try makeModelContext()

        vm.readTodaysNote(modelContext: context)

        #expect(vm.lastReadNote == "# Today\n- Did stuff")

        let descriptor = FetchDescriptor<DailyNote>()
        let notes = try context.fetch(descriptor)
        #expect(notes.count == 1)
        #expect(notes.first?.rawText == "# Today\n- Did stuff")
    }

    @Test func readTodaysNoteUpdatesExisting() throws {
        let obsidian = MockObsidianService()
        obsidian.isVaultConnected = true
        obsidian.mockNoteContent = "Version 1"
        let (vm, _, _) = makeVM(obsidian: obsidian)
        let context = try makeModelContext()

        vm.readTodaysNote(modelContext: context)

        obsidian.mockNoteContent = "Version 2"
        vm.readTodaysNote(modelContext: context)

        let descriptor = FetchDescriptor<DailyNote>()
        let notes = try context.fetch(descriptor)
        #expect(notes.count == 1)
        #expect(notes.first?.rawText == "Version 2")
    }

    @Test func readTodaysNoteSetsErrorWhenNoteNotFound() throws {
        let obsidian = MockObsidianService()
        obsidian.isVaultConnected = true
        obsidian.mockNoteContent = nil
        let (vm, _, _) = makeVM(obsidian: obsidian)
        let context = try makeModelContext()

        vm.readTodaysNote(modelContext: context)

        #expect(vm.errorMessage == "No daily note found for today.")
        #expect(vm.lastReadNote == nil)
    }

    @Test func readTodaysNoteSetsErrorOnReadFailure() throws {
        let obsidian = MockObsidianService()
        obsidian.isVaultConnected = true
        obsidian.shouldThrowOnRead = true
        let (vm, _, _) = makeVM(obsidian: obsidian)
        let context = try makeModelContext()

        vm.readTodaysNote(modelContext: context)

        #expect(vm.errorMessage != nil)
    }

    // MARK: - Claude API Key Management

    @Test func saveAPIKeySavesToService() {
        let claude = MockClaudeAPIService()
        let (vm, _, _) = makeVM(claude: claude)

        vm.apiKeyInput = "sk-test-key-123"
        vm.saveAPIKey()

        #expect(claude.savedAPIKey == "sk-test-key-123")
        #expect(claude.hasAPIKey)
        #expect(vm.apiKeyInput == "")
    }

    @Test func saveAPIKeyRejectsEmptyInput() {
        let (vm, _, claude) = makeVM()

        vm.apiKeyInput = "   "
        vm.saveAPIKey()

        #expect(claude.savedAPIKey == nil)
        #expect(vm.errorMessage != nil)
    }

    @Test func deleteAPIKeyCallsService() {
        let claude = MockClaudeAPIService()
        claude.hasAPIKey = true
        let (vm, _, _) = makeVM(claude: claude)

        vm.deleteAPIKey()

        #expect(claude.deleteCalled)
        #expect(!claude.hasAPIKey)
    }

    @Test func validateAPIKeySetsStatus() async {
        let claude = MockClaudeAPIService()
        claude.hasAPIKey = true
        claude.validateResult = true
        let (vm, _, _) = makeVM(claude: claude)

        await vm.validateAPIKey()

        #expect(claude.validateCalled)
        #expect(vm.apiKeyValidationStatus == "API key is valid.")
        #expect(!vm.isValidatingKey)
    }

    @Test func validateAPIKeySetsErrorOnFailure() async {
        let claude = MockClaudeAPIService()
        claude.hasAPIKey = true
        claude.shouldThrowOnValidate = true
        let (vm, _, _) = makeVM(claude: claude)

        await vm.validateAPIKey()

        #expect(vm.apiKeyValidationStatus != nil)
        #expect(!vm.isValidatingKey)
    }

    // MARK: - Parse Today's Note

    @Test func parseTodaysNoteRequiresLoadedNote() async {
        let (vm, _, _) = makeVM()

        let context = try! makeModelContext()
        await vm.parseTodaysNote(modelContext: context)

        #expect(vm.errorMessage == "No daily note loaded. Read today's note first.")
    }

    @Test func parseTodaysNoteSavesToSwiftData() async throws {
        let claude = MockClaudeAPIService()
        claude.mockParseResult = ClaudeParseResult(categories: [
            .init(category: "workout", content: "Ran 5k"),
            .init(category: "reading", content: "Read a book"),
        ])
        let (vm, _, _) = makeVM(claude: claude)
        vm.lastReadNote = "# Today\n- Ran 5k\n- Read a book"
        let context = try makeModelContext()

        await vm.parseTodaysNote(modelContext: context)

        #expect(vm.parseResultMessage == "Parsed 2 categories.")
        #expect(!vm.isParsing)

        let descriptor = FetchDescriptor<ParsedEntry>()
        let entries = try context.fetch(descriptor)
        #expect(entries.count == 2)
    }

    @Test func parseTodaysNoteSetsErrorOnFailure() async throws {
        let claude = MockClaudeAPIService()
        claude.shouldThrowOnParse = true
        let (vm, _, _) = makeVM(claude: claude)
        vm.lastReadNote = "Some note"
        let context = try makeModelContext()

        await vm.parseTodaysNote(modelContext: context)

        #expect(vm.errorMessage != nil)
        #expect(!vm.isParsing)
    }
}
