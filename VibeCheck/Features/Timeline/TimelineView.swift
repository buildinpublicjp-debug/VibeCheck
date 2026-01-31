import SwiftUI
import SwiftData

struct TimelineView: View {
    @Query(sort: \ParsedEntry.date, order: .reverse) private var entries: [ParsedEntry]
    @State private var viewModel = TimelineViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Entries Yet",
                        systemImage: "calendar.day.timeline.left",
                        description: Text(
                            "Connect your Obsidian vault and parse daily notes to see your timeline."
                        )
                    )
                } else {
                    timelineContent
                }
            }
            .navigationTitle("Timeline")
            .navigationDestination(for: Date.self) { date in
                DayDetailView(date: date)
            }
        }
    }

    private var weekGroups: [WeekGroup] {
        viewModel.groupedByWeek(entries: entries, filterCategory: viewModel.selectedCategory)
    }

    @ViewBuilder
    private var timelineContent: some View {
        let groups = weekGroups
        if groups.isEmpty {
            ContentUnavailableView(
                "No Matching Entries",
                systemImage: "line.3.horizontal.decrease.circle",
                description: Text("Try removing the filter to see all entries.")
            )
            .safeAreaInset(edge: .top) {
                CategoryFilterBar(selectedCategory: $viewModel.selectedCategory)
                    .padding(.vertical, 8)
            }
        } else {
            List {
                ForEach(groups) { weekGroup in
                    WeekSection(weekGroup: weekGroup)
                }
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .top) {
                CategoryFilterBar(selectedCategory: $viewModel.selectedCategory)
                    .padding(.vertical, 8)
                    .background(.bar)
            }
        }
    }
}
