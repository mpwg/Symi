#if os(macOS)
import SwiftUI

struct MacSyncWorkspaceView: View {
    let model: MacAppModel

    var body: some View {
        let controller = model.settingsController

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                MacSectionIntro(
                    eyebrow: "Synchronisation",
                    title: "Cloud-Zustand als Arbeitsfläche",
                    detail: "Status, Konflikte und Wiederherstellung leben auf dem Desktop nebeneinander statt in verschachtelten Mobil-Listen."
                )

                MacSurfaceCard(title: "Überblick") {
                    HStack(spacing: 12) {
                        MacMetricBadge(title: "Aktive Episoden", value: "\(controller.summary.activeEpisodeCount)", tint: .blue)
                        MacMetricBadge(title: "Papierkorb", value: "\(controller.summary.trashCount)", tint: .orange)
                        MacMetricBadge(title: "Konflikte", value: "\(controller.summary.conflictCount)", tint: .red)
                    }
                }

                MacSurfaceCard(title: "Aktionen", subtitle: "App-Einstellung und manuelle Läufe") {
                    Toggle(
                        "iCloud-Synchronisation aktivieren",
                        isOn: Binding(
                            get: { controller.isSyncEnabled },
                            set: { controller.setSyncEnabled($0) }
                        )
                    )
                    .toggleStyle(.switch)

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

                        Button("Zum Export wechseln") {
                            model.selectRoute(.export)
                        }
                    }
                }

                MacSurfaceCard(title: "Konflikte", subtitle: "Nur sichtbar, solange Entscheidungen fehlen") {
                    if controller.conflicts.isEmpty {
                        Text("Keine offenen Konflikte.")
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(controller.conflicts) { conflict in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(conflictTitle(for: conflict))
                                        .font(.headline)

                                    Text("Abweichende Felder: \(conflict.conflictingFields.joined(separator: ", "))")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    HStack {
                                        Button("Lokale Version behalten") {
                                            controller.resolveConflictKeepingLocal(conflict)
                                        }
                                        .buttonStyle(.bordered)

                                        Button("Cloud-Version übernehmen") {
                                            controller.resolveConflictUsingRemote(conflict)
                                        }
                                        .buttonStyle(.borderedProminent)
                                    }
                                }
                                .padding(.bottom, 6)
                            }
                        }
                    }
                }

                MacSurfaceCard(title: "Papierkorb", subtitle: "Lokal und in der Cloud sichtbar, bis du bewusst wiederherstellst") {
                    if controller.deletedEpisodes.isEmpty && controller.deletedDefinitions.isEmpty {
                        Text("Keine gelöschten Einträge.")
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(controller.deletedEpisodes) { episode in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(episode.startedAt.formatted(date: .abbreviated, time: .shortened))
                                        Text(episode.type.rawValue)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Button("Wiederherstellen") {
                                        controller.restoreEpisode(id: episode.id)
                                    }
                                }
                            }

                            ForEach(controller.deletedDefinitions) { definition in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(definition.name)
                                        Text(definition.category.rawValue)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Button("Wiederherstellen") {
                                        controller.restoreMedicationDefinition(definition)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .task {
            controller.load()
            controller.refreshLog(limit: 50)
        }
    }

    private func conflictTitle(for conflict: SyncConflict) -> String {
        switch conflict.entityType {
        case .episode:
            "Episode"
        case .medicationDefinition:
            "Medikamentenvorlage"
        }
    }
}

struct MacSyncInspectorView: View {
    let controller: SettingsController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                MacSectionIntro(
                    eyebrow: "Inspector",
                    title: "Status und Protokoll",
                    detail: "Zeitpunkte, Fehler und letzte Aktivitäten bleiben dauerhaft sichtbar."
                )

                MacSurfaceCard(title: "Synchronisationsstatus") {
                    HStack {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 10, height: 10)
                        Text(controller.syncStatus.state.displayTitle)
                            .font(.headline)
                    }

                    MacInspectorFactRow(title: "Dienst", value: controller.syncStatus.service)
                    MacInspectorFactRow(title: "Ausstehende Uploads", value: "\(controller.syncStatus.queuedUpdates)")
                    MacInspectorFactRow(title: "Ungesyncte Einträge", value: "\(controller.syncStatus.unsyncedRecords)")
                    MacInspectorFactRow(title: "Letzter Download", value: formatted(controller.syncStatus.lastDownloadedAt))
                    MacInspectorFactRow(title: "Letzter Upload", value: formatted(controller.syncStatus.lastUploadedAt))

                    if let lastError = controller.syncStatus.lastError {
                        Label(lastError, systemImage: "exclamationmark.triangle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                    }
                }

                MacSurfaceCard(title: "Sync-Protokoll") {
                    if let shareURL = controller.logShareURL {
                        ShareLink(item: shareURL) {
                            Label("Protokoll teilen", systemImage: "square.and.arrow.up")
                        }
                    }

                    Button("Protokoll leeren", role: .destructive) {
                        controller.clearLog()
                    }

                    if controller.logEntries.isEmpty {
                        Text("Noch keine Einträge.")
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(controller.logEntries.prefix(8)) { entry in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                    Text(entry.message)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .frame(minWidth: 320, idealWidth: 360, maxWidth: 420, maxHeight: .infinity, alignment: .topLeading)
    }

    private var statusColor: Color {
        switch controller.syncStatus.state {
        case .ready:
            .green
        case .syncing:
            .blue
        case .conflict, .needsAttention:
            .orange
        case .noICloudAccount, .offline:
            .red
        case .disabled:
            .gray
        }
    }

    private func formatted(_ date: Date?) -> String {
        guard let date else {
            return "Noch nie"
        }

        return date.formatted(date: .abbreviated, time: .shortened)
    }
}
#endif
