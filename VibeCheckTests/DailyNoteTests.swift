import Testing
import Foundation
@testable import VibeCheck

struct DailyNoteTests {

    // MARK: - Initialization

    @Test func initNormalizesDateToStartOfDay() {
        let calendar = Calendar.current
        let afternoon = calendar.date(bySettingHour: 15, minute: 30, second: 0, of: .now)!
        let note = DailyNote(date: afternoon, rawText: "# Test", filename: "2026-01-31.md")

        let expected = calendar.startOfDay(for: afternoon)
        #expect(note.date == expected)
    }

    @Test func initSetsAllFields() {
        let note = DailyNote(date: .now, rawText: "# My Note\nSome content", filename: "2026-01-31.md")

        #expect(note.rawText == "# My Note\nSome content")
        #expect(note.filename == "2026-01-31.md")
    }

    @Test func initSetsTimestamps() {
        let before = Date.now
        let note = DailyNote(date: .now, rawText: "", filename: "2026-01-31.md")
        let after = Date.now

        #expect(note.createdAt >= before)
        #expect(note.createdAt <= after)
        #expect(note.updatedAt >= before)
        #expect(note.updatedAt <= after)
    }

    // MARK: - Content

    @Test func rawTextPreservesMarkdown() {
        let markdown = """
        # Daily Note
        ## Workout
        - Ran 5km
        ## Reading
        - Finished chapter 3
        """
        let note = DailyNote(date: .now, rawText: markdown, filename: "2026-01-31.md")

        #expect(note.rawText.contains("# Daily Note"))
        #expect(note.rawText.contains("- Ran 5km"))
    }

    @Test func emptyRawTextIsValid() {
        let note = DailyNote(date: .now, rawText: "", filename: "2026-01-31.md")
        #expect(note.rawText.isEmpty)
    }
}
