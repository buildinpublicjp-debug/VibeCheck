import Foundation
import SwiftData
import os

@Observable
@MainActor
final class SettingsViewModel {
    var isShowingPicker = false
    var errorMessage: String?
    var lastReadNote: String?

    private let obsidianService: ObsidianServiceProtocol
    private let logger = Logger(subsystem: "com.vibecheck", category: "SettingsViewModel")

    var isVaultConnected: Bool { obsidianService.isVaultConnected }
    var vaultName: String? { obsidianService.vaultName }
    var dailyNotesFolder: String { obsidianService.dailyNotesFolder }

    init(obsidianService: ObsidianServiceProtocol) {
        self.obsidianService = obsidianService
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
}
