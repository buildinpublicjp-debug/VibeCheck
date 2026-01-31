import Foundation
import SwiftData
import os

@Observable
@MainActor
final class SettingsViewModel {
    var isShowingPicker = false
    var errorMessage: String?
    var lastReadNote: String?

    // Claude API state
    var apiKeyInput = ""
    var isAPIKeyConfigured: Bool { claudeAPIService.hasAPIKey }
    var isValidatingKey = false
    var apiKeyValidationStatus: String?
    var isParsing = false
    var parseResultMessage: String?

    private let obsidianService: ObsidianServiceProtocol
    private let claudeAPIService: ClaudeAPIServiceProtocol
    private let logger = Logger(subsystem: "com.vibecheck", category: "SettingsViewModel")

    var isVaultConnected: Bool { obsidianService.isVaultConnected }
    var vaultName: String? { obsidianService.vaultName }
    var dailyNotesFolder: String { obsidianService.dailyNotesFolder }

    init(obsidianService: ObsidianServiceProtocol, claudeAPIService: ClaudeAPIServiceProtocol) {
        self.obsidianService = obsidianService
        self.claudeAPIService = claudeAPIService
    }

    func connectVault(url: URL) {
        do {
            try obsidianService.storeBookmark(for: url)
            logger.info("Vault connected: \(url.lastPathComponent)")
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Failed to connect vault: \(error)")
        }
    }

    func disconnectVault() {
        obsidianService.clearVault()
        lastReadNote = nil
        logger.info("Vault disconnected.")
    }

    func readTodaysNote(modelContext: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)

        do {
            guard let content = try obsidianService.readDailyNote(for: today) else {
                errorMessage = "No daily note found for today."
                return
            }

            let filename = ObsidianService.filename(for: today)
            saveDailyNote(date: today, rawText: content, filename: filename, modelContext: modelContext)
            lastReadNote = content
            logger.info("Read today's note (\(content.count) chars)")
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Failed to read today's note: \(error)")
        }
    }

    private func saveDailyNote(date: Date, rawText: String, filename: String, modelContext: ModelContext) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        var descriptor = FetchDescriptor<DailyNote>(
            predicate: #Predicate { $0.date == startOfDay }
        )
        descriptor.fetchLimit = 1

        do {
            let existing = try modelContext.fetch(descriptor)
            if let note = existing.first {
                note.rawText = rawText
                note.filename = filename
                note.updatedAt = .now
            } else {
                let note = DailyNote(date: date, rawText: rawText, filename: filename)
                modelContext.insert(note)
            }
            try modelContext.save()
        } catch {
            logger.error("Failed to save daily note: \(error)")
            errorMessage = "Failed to save note: \(error.localizedDescription)"
        }
    }

    // MARK: - Claude API

    func saveAPIKey() {
        let key = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            errorMessage = "API key cannot be empty."
            return
        }

        do {
            try claudeAPIService.saveAPIKey(key)
            apiKeyInput = ""
            apiKeyValidationStatus = nil
            parseResultMessage = nil
            logger.info("API key saved.")
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Failed to save API key: \(error)")
        }
    }

    func deleteAPIKey() {
        do {
            try claudeAPIService.deleteAPIKey()
            apiKeyValidationStatus = nil
            parseResultMessage = nil
            logger.info("API key deleted.")
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Failed to delete API key: \(error)")
        }
    }

    func validateAPIKey() async {
        isValidatingKey = true
        apiKeyValidationStatus = nil

        do {
            let valid = try await claudeAPIService.validateAPIKey()
            apiKeyValidationStatus = valid ? "API key is valid." : "API key is invalid."
        } catch {
            apiKeyValidationStatus = error.localizedDescription
        }

        isValidatingKey = false
    }

    func parseTodaysNote(modelContext: ModelContext) async {
        guard let noteContent = lastReadNote else {
            errorMessage = "No daily note loaded. Read today's note first."
            return
        }

        isParsing = true
        parseResultMessage = nil

        do {
            let result = try await claudeAPIService.parseDailyNote(noteContent)
            saveParsedEntries(result, modelContext: modelContext)
            parseResultMessage = "Parsed \(result.categories.count) categories."
            logger.info("Parsed today's note: \(result.categories.count) categories")
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Failed to parse today's note: \(error)")
        }

        isParsing = false
    }

    private func saveParsedEntries(_ result: ClaudeParseResult, modelContext: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)

        for item in result.categories {
            guard let category = EntryCategory(rawValue: item.category) else { continue }

            let rawValue = category.rawValue
            var descriptor = FetchDescriptor<ParsedEntry>(
                predicate: #Predicate { $0.date == today && $0.categoryRawValue == rawValue }
            )
            descriptor.fetchLimit = 1

            do {
                let existing = try modelContext.fetch(descriptor)
                if let entry = existing.first {
                    entry.content = item.content
                    entry.updatedAt = .now
                } else {
                    let entry = ParsedEntry(
                        date: today,
                        category: category,
                        content: item.content,
                        dailyNoteDate: today
                    )
                    modelContext.insert(entry)
                }
            } catch {
                logger.error("Failed to save parsed entry for \(rawValue): \(error)")
            }
        }

        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save model context: \(error)")
            errorMessage = "Failed to save parsed entries: \(error.localizedDescription)"
        }
    }
}
