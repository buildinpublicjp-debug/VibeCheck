import Foundation
import SwiftData

@Model
final class DailyNote {
    #Unique<DailyNote>([\.date])

    var date: Date
    var rawText: String
    var filename: String

    var createdAt: Date
    var updatedAt: Date

    init(date: Date, rawText: String, filename: String) {
        let calendar = Calendar.current
        self.date = calendar.startOfDay(for: date)
        self.rawText = rawText
        self.filename = filename
        self.createdAt = .now
        self.updatedAt = .now
    }
}
