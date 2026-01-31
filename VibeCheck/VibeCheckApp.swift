import SwiftUI
import SwiftData

@main
struct VibeCheckApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DailySummary.self,
            DailyNote.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var healthKitService = HealthKitService.shared
    @State private var obsidianService = ObsidianService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(healthKitService)
                .environment(obsidianService)
        }
        .modelContainer(sharedModelContainer)
    }
}
