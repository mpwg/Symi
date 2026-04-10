import SwiftUI

@MainActor
final class AppLogViewModel: ObservableObject {
    @Published private(set) var entries: [AppLogEntry] = []
    @Published var filter: AppLogFilter = .all
    @Published private(set) var shareURL: URL?

    private let store: AppLogStore

    init(store: AppLogStore) {
        self.store = store
    }

    func refresh(limit: Int = 200) {
        Task {
            let entries = await store.recentEntries(filter: filter, limit: limit)
            let shareURL = await store.exportLogFileURL(filter: filter)
            await MainActor.run {
                self.entries = entries
                self.shareURL = shareURL
            }
        }
    }

    func updateFilter(_ filter: AppLogFilter) {
        self.filter = filter
        refresh()
    }

    func clear() {
        Task {
            await store.clear()
            await MainActor.run {
                self.entries = []
                self.shareURL = nil
            }
        }
    }
}

struct SyncLogView: View {
    @EnvironmentObject private var appLogViewModel: AppLogViewModel

    var body: some View {
        List {
            Section {
                Text("Das Protokoll bleibt lokal auf diesem Gerät. Es enthält technische Metadaten zu Synchronisation, Konflikten und Fehlern, aber keine sensiblen Freitextinhalte im Klartext.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Filter") {
                Picker("Ansicht", selection: filterBinding) {
                    Text("Alle").tag(AppLogFilter.all)
                    Text("Nur Fehler").tag(AppLogFilter.errors)
                    Text("Nur Sync").tag(AppLogFilter.sync)
                }
                .pickerStyle(.segmented)
            }

            Section("Aktionen") {
                Button("Aktualisieren") {
                    appLogViewModel.refresh()
                }

                if let shareURL = appLogViewModel.shareURL {
                    ShareLink(item: shareURL) {
                        Label("Protokoll teilen", systemImage: "square.and.arrow.up")
                    }
                }

                Button("Protokoll löschen", role: .destructive) {
                    appLogViewModel.clear()
                }
                .disabled(appLogViewModel.entries.isEmpty)
            }

            Section("Einträge") {
                if appLogViewModel.entries.isEmpty {
                    ContentUnavailableView(
                        "Kein Protokoll vorhanden",
                        systemImage: "text.page.slash",
                        description: Text("Sobald Sync-Vorgänge oder Fehler auftreten, erscheinen sie hier.")
                    )
                } else {
                    ForEach(appLogViewModel.entries) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: iconName(for: entry.level))
                                    .foregroundStyle(color(for: entry.level))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.operation)
                                        .font(.headline)
                                    Text(entry.message)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(entry.timestamp.formatted(date: .abbreviated, time: .standard))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if !entry.metadata.isEmpty {
                                Text(entry.metadata.map { "\($0.key): \($0.value)" }.sorted().joined(separator: " · "))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Sync-Protokoll")
        .task {
            appLogViewModel.refresh()
        }
        .refreshable {
            appLogViewModel.refresh()
        }
    }

    private var filterBinding: Binding<AppLogFilter> {
        Binding(
            get: { appLogViewModel.filter },
            set: { appLogViewModel.updateFilter($0) }
        )
    }

    private func iconName(for level: AppLogLevel) -> String {
        switch level {
        case .debug:
            "ladybug"
        case .info:
            "info.circle"
        case .warning:
            "exclamationmark.triangle"
        case .error:
            "xmark.octagon"
        }
    }

    private func color(for level: AppLogLevel) -> Color {
        switch level {
        case .debug:
            .blue
        case .info:
            .green
        case .warning:
            .orange
        case .error:
            .red
        }
    }
}
