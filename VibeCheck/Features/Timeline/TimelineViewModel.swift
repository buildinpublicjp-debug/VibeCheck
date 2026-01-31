import Foundation

struct WeekGroup: Identifiable {
    let id: Date
    let startDate: Date
    let endDate: Date
    let dayGroups: [DayGroup]

    var displayRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
    }
}

struct DayGroup: Identifiable {
    let id: Date
    let date: Date
    let entries: [ParsedEntry]

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }
}

@Observable
final class TimelineViewModel {
    var selectedCategory: EntryCategory?

    func groupedByWeek(entries: [ParsedEntry], filterCategory: EntryCategory?) -> [WeekGroup] {
        let calendar = Calendar.current

        let filtered: [ParsedEntry]
        if let category = filterCategory {
            filtered = entries.filter { $0.category == category }
        } else {
            filtered = entries
        }

        let dayGrouped = Dictionary(grouping: filtered) { entry in
            calendar.startOfDay(for: entry.date)
        }

        let dayGroups = dayGrouped.map { date, entries in
            DayGroup(
                id: date,
                date: date,
                entries: entries.sorted { $0.categoryRawValue < $1.categoryRawValue }
            )
        }

        let weekGrouped = Dictionary(grouping: dayGroups) { dayGroup in
            calendar.dateInterval(of: .weekOfYear, for: dayGroup.date)?.start ?? dayGroup.date
        }

        let weekGroups = weekGrouped.compactMap { weekStart, dayGroups -> WeekGroup? in
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: weekStart) else {
                return nil
            }
            let sortedDays = dayGroups.sorted { $0.date > $1.date }
            let endDate = calendar.date(byAdding: .day, value: -1, to: weekInterval.end)
                ?? weekInterval.end
            return WeekGroup(
                id: weekStart,
                startDate: weekInterval.start,
                endDate: endDate,
                dayGroups: sortedDays
            )
        }

        return weekGroups.sorted { $0.startDate > $1.startDate }
    }
}
