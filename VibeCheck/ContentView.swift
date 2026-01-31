import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "heart.text.clipboard") {
                DashboardView()
            }

            Tab("Timeline", systemImage: "calendar.day.timeline.left") {
                Text("Timeline")
                    .foregroundStyle(.secondary)
            }

            Tab("Settings", systemImage: "gearshape") {
                SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [DailySummary.self, DailyNote.self, ParsedEntry.self], inMemory: true)
        .environment(HealthKitService())
        .environment(ObsidianService())
        .environment(ClaudeAPIService())
}
