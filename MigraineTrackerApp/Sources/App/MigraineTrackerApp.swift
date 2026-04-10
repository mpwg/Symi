import SwiftUI
import SwiftData

@main
struct MigraineTrackerApp: App {
    private let modelContainer: ModelContainer
    private let appLogStore: AppLogStore
    @StateObject private var syncCoordinator: SyncCoordinator
    @StateObject private var appLogViewModel: AppLogViewModel

    init() {
        let schema = Schema(versionedSchema: MigraineTrackerSchemaV2.self)

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )

        do {
            let container = try ModelContainer(
                for: schema,
                migrationPlan: MigraineTrackerMigrationPlan.self,
                configurations: [configuration]
            )
            MedicationCatalog.importSeedDataIfNeeded(into: container)
            self.modelContainer = container
            let appLogStore = AppLogStore()
            self.appLogStore = appLogStore
            _syncCoordinator = StateObject(wrappedValue: SyncCoordinator(modelContainer: container, appLogStore: appLogStore))
            _appLogViewModel = StateObject(wrappedValue: AppLogViewModel(store: appLogStore))
        } catch {
            fatalError("ModelContainer konnte nicht erstellt werden: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .environmentObject(syncCoordinator)
                .environmentObject(appLogViewModel)
        }
        .modelContainer(modelContainer)
    }
}
