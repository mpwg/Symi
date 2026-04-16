#if os(macOS)
import Observation
import SwiftUI

@MainActor
@Observable
final class MacAppModel {
    let appContainer: AppContainer
    let historyController: HistoryController
    let settingsController: SettingsController
    let exportController: DataExportController

    var captureController: EpisodeEditorController
    var selectedRoute: MacRoute = .defaultRoute
    var columnVisibility: NavigationSplitViewVisibility = .all
    var selectedHistoryEpisodeID: UUID?

    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self.historyController = appContainer.makeHistoryController()
        self.settingsController = appContainer.makeSettingsController()
        self.exportController = appContainer.makeDataExportController()
        self.captureController = appContainer.makeEpisodeEditorController(
            initialStartedAt: historyController.defaultStartDateForSelectedDay()
        )
        self.selectedHistoryEpisodeID = historyController.selectedDayEpisodes.first?.id
    }

    var showsInspector: Bool {
        columnVisibility == .all
    }

    var selectedHistoryEpisode: EpisodeRecord? {
        guard let selectedHistoryEpisodeID else {
            return nil
        }

        return historyController.selectedDayEpisodes.first { $0.id == selectedHistoryEpisodeID }
    }

    func prepare() {
        settingsController.load()
        settingsController.refreshLog(limit: 50)
        exportController.reloadSummary()
        refreshHistorySelection()
    }

    func selectRoute(_ route: MacRoute) {
        selectedRoute = route
        if route == .history {
            refreshHistorySelection()
        }
    }

    func focusToday() {
        selectedRoute = .history
        historyController.selectDay(.now)
        refreshHistorySelection()
    }

    func startNewEpisode() {
        selectedRoute = .capture
        resetCapture()
    }

    func resetCapture() {
        captureController = appContainer.makeEpisodeEditorController(
            initialStartedAt: historyController.defaultStartDateForSelectedDay()
        )
    }

    func selectHistoryDay(_ day: Date) {
        historyController.selectDay(day)
        refreshHistorySelection()
    }

    func selectHistoryEpisode(_ episodeID: UUID?) {
        selectedHistoryEpisodeID = episodeID
    }

    func refreshHistorySelection() {
        if let selectedHistoryEpisode, historyController.selectedDayEpisodes.contains(selectedHistoryEpisode) {
            return
        }

        selectedHistoryEpisodeID = historyController.selectedDayEpisodes.first?.id
    }

    func toggleInspector() {
        columnVisibility = showsInspector ? .doubleColumn : .all
    }
}
#endif
