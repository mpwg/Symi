#if os(macOS)
import SwiftUI

struct MacSettingsRootView: View {
    let model: MacAppModel

    @State private var selectedPane: MacSettingsPane = .sync

    var body: some View {
        TabView(selection: $selectedPane) {
            MacSettingsSyncPane(controller: model.settingsController)
                .tabItem {
                    Label(MacSettingsPane.sync.title, systemImage: MacSettingsPane.sync.systemImage)
                }
                .tag(MacSettingsPane.sync)

            NavigationStack {
                ProductInformationView(mode: .standard)
            }
            .tabItem {
                Label(MacSettingsPane.privacy.title, systemImage: MacSettingsPane.privacy.systemImage)
            }
            .tag(MacSettingsPane.privacy)
        }
        .frame(minWidth: 760, minHeight: 560)
        .task {
            model.settingsController.load()
            model.settingsController.refreshLog(limit: 30)
        }
    }
}

struct MacPrivacyInformationWindowView: View {
    var body: some View {
        NavigationStack {
            ProductInformationView(mode: .standard)
        }
        .frame(minWidth: 640, minHeight: 720)
    }
}

private struct MacSettingsSyncPane: View {
    let controller: SettingsController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                MacSectionIntro(
                    eyebrow: "Einstellungen",
                    title: "Synchronisation und App-Verhalten",
                    detail: "App-weite Optionen wohnen in einem separaten Settings-Fenster und nicht im Hauptarbeitsbereich."
                )

                MacSurfaceCard(title: "Einstellung") {
                    Toggle(
                        "iCloud-Synchronisation aktivieren",
                        isOn: Binding(
                            get: { controller.isSyncEnabled },
                            set: { controller.setSyncEnabled($0) }
                        )
                    )

                    Text("Die App bleibt vollständig lokal nutzbar. Erst mit Aktivierung wird iCloud für private Sync-Daten verwendet.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                MacSurfaceCard(title: "Status") {
                    HStack(spacing: 12) {
                        MacMetricBadge(title: "Aktive Episoden", value: "\(controller.summary.activeEpisodeCount)", tint: .blue)
                        MacMetricBadge(title: "Papierkorb", value: "\(controller.summary.trashCount)", tint: .orange)
                        MacMetricBadge(title: "Konflikte", value: "\(controller.summary.conflictCount)", tint: .red)
                    }

                    if let lastError = controller.syncStatus.lastError {
                        Label(lastError, systemImage: "exclamationmark.triangle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                    }
                }

                MacSurfaceCard(title: "Schnellaktionen") {
                    HStack {
                        Button("Jetzt synchronisieren") {
                            Task {
                                await controller.syncNow()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!controller.isSyncEnabled)

                        Button("Fehler erneut versuchen") {
                            Task {
                                await controller.retryLastError()
                            }
                        }
                        .disabled(!controller.isSyncEnabled || controller.syncStatus.lastError == nil)
                    }
                }
            }
            .padding(24)
        }
    }
}
#endif
