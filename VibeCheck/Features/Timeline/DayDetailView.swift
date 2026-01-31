import SwiftUI
import SwiftData

struct DayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DayDetailViewModel

    let date: Date

    @Query private var entries: [ParsedEntry]

    init(date: Date) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        self.date = normalizedDate
        self._viewModel = State(initialValue: DayDetailViewModel(date: normalizedDate))

        let start = normalizedDate
        let end = Calendar.current.date(byAdding: .day, value: 1, to: normalizedDate)!
        self._entries = Query(
            filter: #Predicate<ParsedEntry> { entry in
                entry.date >= start && entry.date < end
            },
            sort: \ParsedEntry.categoryRawValue
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let summary = viewModel.dailySummary {
                    healthSection(summary: summary)
                }

                if !entries.isEmpty {
                    entriesSection
                }

                if let note = viewModel.dailyNote {
                    dailyNoteSection(note: note)
                }

                if viewModel.dailySummary == nil && entries.isEmpty && viewModel.dailyNote == nil {
                    ContentUnavailableView(
                        "No Data",
                        systemImage: "doc.text",
                        description: Text("No health data or entries found for this day.")
                    )
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(formattedTitle)
        .navigationBarTitleDisplayMode(.large)
        .task {
            viewModel.loadData(modelContext: modelContext)
        }
    }

    private var formattedTitle: String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    // MARK: - Health Summary

    @ViewBuilder
    private func healthSection(summary: DailySummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Health", systemImage: "heart.fill")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ], spacing: 12) {
                healthTile(
                    icon: "figure.walk",
                    label: "Steps",
                    value: summary.formattedSteps ?? "—",
                    tint: .orange
                )
                healthTile(
                    icon: "bed.double.fill",
                    label: "Sleep",
                    value: summary.formattedSleep ?? "—",
                    tint: .indigo
                )
                healthTile(
                    icon: "scalemass.fill",
                    label: "Weight",
                    value: summary.formattedWeight ?? "—",
                    tint: .green
                )
                healthTile(
                    icon: "heart.fill",
                    label: "Heart Rate",
                    value: summary.formattedHeartRate ?? "—",
                    tint: .red
                )
            }
        }
    }

    private func healthTile(icon: String, label: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(tint)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Entries

    private var entriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Entries", systemImage: "list.bullet")
                .font(.headline)

            ForEach(entries, id: \.id) { entry in
                EntryCard(entry: entry)
            }
        }
    }

    // MARK: - Daily Note

    @ViewBuilder
    private func dailyNoteSection(note: DailyNote) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Daily Note", systemImage: "doc.text")
                .font(.headline)

            Text(note.rawText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
