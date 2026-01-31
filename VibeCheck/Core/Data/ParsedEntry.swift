import Foundation
import SwiftData

enum EntryCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case workout, reading, insight, work, food, health

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .workout: "Workout"
        case .reading: "Reading"
        case .insight: "Insight"
        case .work: "Work"
        case .food: "Food"
        case .health: "Health"
        }
    }

    var systemImage: String {
        switch self {
        case .workout: "figure.run"
        case .reading: "book"
        case .insight: "lightbulb"
        case .work: "laptopcomputer"
        case .food: "fork.knife"
        case .health: "heart"
        }
    }
}

@Model
final class ParsedEntry {
    #Unique<ParsedEntry>([\.date, \.categoryRawValue])

    var date: Date
    var categoryRawValue: String
    var content: String
    var dailyNoteDate: Date
    var createdAt: Date
    var updatedAt: Date

    var category: EntryCategory? {
        EntryCategory(rawValue: categoryRawValue)
    }

    init(date: Date, category: EntryCategory, content: String, dailyNoteDate: Date) {
        let calendar = Calendar.current
        self.date = calendar.startOfDay(for: date)
        self.categoryRawValue = category.rawValue
        self.content = content
        self.dailyNoteDate = calendar.startOfDay(for: dailyNoteDate)
        self.createdAt = .now
        self.updatedAt = .now
    }
}
