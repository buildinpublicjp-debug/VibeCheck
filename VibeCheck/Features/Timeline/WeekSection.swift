import SwiftUI

struct WeekSection: View {
    let weekGroup: WeekGroup

    var body: some View {
        Section {
            ForEach(weekGroup.dayGroups) { dayGroup in
                NavigationLink(value: dayGroup.date) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(dayGroup.displayDate)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)

                        ForEach(dayGroup.entries, id: \.id) { entry in
                            EntryCard(entry: entry)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text(weekGroup.displayRange)
                .font(.headline)
                .foregroundStyle(.primary)
                .textCase(nil)
        }
    }
}
