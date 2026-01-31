import Foundation

protocol ObsidianServiceProtocol: Sendable {
    var isVaultConnected: Bool { get }
    var vaultName: String? { get }
    var dailyNotesFolder: String { get }
    func storeBookmark(for url: URL) throws
    func resolveBookmark() throws -> URL
    func readDailyNote(for date: Date) throws -> String?
    func clearVault()
}
