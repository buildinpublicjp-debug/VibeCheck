import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(HealthKitService.self) private var healthKitService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailySummary.date, order: .reverse) private var allSummaries: [DailySummary]

    @State private var viewModel: DashboardViewModel?

    private var weekSummaries: [DailySummary] {
        Array(allSummaries.prefix(7))
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection

                    if let vm = viewModel, vm.isLoading && allSummaries.isEmpty {
                        loadingView
                    } else if allSummaries.isEmpty {
                        emptyView
                    } else {
                        cardsGrid
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("VibeCheck")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    refreshButton
                }
            }
            .task {
                let vm = DashboardViewModel(healthKitService: healthKitService)
                viewModel = vm
                await vm.requestAccessAndLoad(modelContext: modelContext)
            }
            .refreshable {
                await viewModel?.loadWeekData(modelContext: modelContext)
            }
            .alert("Error", isPresented: hasError) {
                Button("OK") { viewModel?.errorMessage = nil }
            } message: {
                if let msg = viewModel?.errorMessage {
                    Text(msg)
                }
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.title2.weight(.semibold))
            Text(Date.now.formatted(date: .complete, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var cardsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            StepsCard(summaries: weekSummaries)
            SleepCard(summaries: weekSummaries)
            WeightCard(summaries: weekSummaries)
            HeartRateCard(summaries: weekSummaries)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading health data...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Health Data",
            systemImage: "heart.text.clipboard",
            description: Text("Tap refresh to load your health data from HealthKit.")
        )
    }

    private var refreshButton: some View {
        Button {
            Task { await viewModel?.loadWeekData(modelContext: modelContext) }
        } label: {
            if viewModel?.isLoading == true {
                ProgressView()
            } else {
                Image(systemName: "arrow.clockwise")
            }
        }
        .disabled(viewModel?.isLoading == true)
    }

    private var hasError: Binding<Bool> {
        .init(
            get: { viewModel?.errorMessage != nil },
            set: { if !$0 { viewModel?.errorMessage = nil } }
        )
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: DailySummary.self, inMemory: true)
        .environment(HealthKitService())
}
