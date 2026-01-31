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
                Text("Settings")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: DailySummary.self, inMemory: true)
        .environment(HealthKitService())
}
