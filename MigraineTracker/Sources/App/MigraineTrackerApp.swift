import SwiftUI
import SwiftData

@main
struct MigraineTrackerApp: App {
    private let modelContainer: ModelContainer
    private let appLogStore: AppLogStore
    @State private var syncCoordinator: SyncCoordinator
    @State private var appLogViewModel: AppLogViewModel

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
            _syncCoordinator = State(initialValue: SyncCoordinator(modelContainer: container, appLogStore: appLogStore))
            _appLogViewModel = State(initialValue: AppLogViewModel(store: appLogStore))
        } catch {
            fatalError("ModelContainer konnte nicht erstellt werden: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .environment(syncCoordinator)
                .environment(appLogViewModel)
        }
        .modelContainer(modelContainer)
    }
}
