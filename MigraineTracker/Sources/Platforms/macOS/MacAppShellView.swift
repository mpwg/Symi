#if os(macOS)
import SwiftUI

struct MacAppShellView: View {
    let model: MacAppModel

    var body: some View {
        NavigationSplitView(
            columnVisibility: Binding(
                get: { model.columnVisibility },
                set: { model.columnVisibility = $0 }
            )
        ) {
            List(
                MacRoute.allCases,
                selection: Binding(
                    get: { model.selectedRoute },
                    set: { model.selectRoute($0 ?? .defaultRoute) }
                )
            ) { route in
                VStack(alignment: .leading, spacing: 6) {
                    Label(route.title, systemImage: route.systemImage)
                        .font(.headline)

                    Text(route.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 6)
                .tag(route)
            }
            .listStyle(.sidebar)
            .navigationTitle("Migraine Tracker")
        } content: {
            ZStack {
                MacWorkspaceBackground()
                workspaceContent
            }
        } detail: {
            ZStack {
                MacWorkspaceBackground()
                workspaceInspector
            }
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    model.focusToday()
                } label: {
                    Label("Heute", systemImage: "calendar.badge.clock")
                }

                Button {
                    model.startNewEpisode()
                } label: {
                    Label("Neue Episode", systemImage: "plus")
                }

                Button {
                    model.toggleInspector()
                } label: {
                    Label(
                        model.showsInspector ? "Inspector ausblenden" : "Inspector einblenden",
                        systemImage: model.showsInspector ? "sidebar.right" : "sidebar.right"
                    )
                }
            }
        }
        .task {
            await model.appContainer.weatherBackfillService.runIfNeeded()
            model.prepare()
        }
    }

    @ViewBuilder
    private var workspaceContent: some View {
        switch model.selectedRoute {
        case .history:
            MacHistoryWorkspaceView(model: model)
        case .capture:
            MacEpisodeCaptureWorkspaceView(model: model)
        case .sync:
            MacSyncWorkspaceView(model: model)
        case .export:
            MacExportWorkspaceView(model: model)
        }
    }

    @ViewBuilder
    private var workspaceInspector: some View {
        switch model.selectedRoute {
        case .history:
            MacHistoryInspectorView(model: model)
        case .capture:
            MacEpisodeCaptureInspectorView(controller: model.captureController, resetCapture: model.resetCapture)
        case .sync:
            MacSyncInspectorView(controller: model.settingsController)
        case .export:
            MacExportInspectorView(controller: model.exportController)
        }
    }
}
#endif
