import SwiftUI
import SwiftData

@main
struct MigraineTrackerApp: App {
    private let modelContainer: ModelContainer = {
        let schema = Schema([
            Episode.self,
            MedicationEntry.self,
            MedicationDefinition.self,
            WeatherSnapshot.self,
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            MedicationCatalog.importSeedDataIfNeeded(into: container)
            return container
        } catch {
            fatalError("ModelContainer konnte nicht erstellt werden: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppShellView()
        }
        .modelContainer(modelContainer)
    }
}
