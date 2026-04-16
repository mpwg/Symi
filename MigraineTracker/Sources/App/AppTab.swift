import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case capture
    case history
    case syncAndExport
    case settings

    nonisolated var id: String { rawValue }

    nonisolated var title: String {
        switch self {
        case .home:
            "Heute"
        case .capture:
            "Erfassen"
        case .history:
            "Verlauf"
        case .syncAndExport:
            "Sync & Export"
        case .settings:
            "Einstellungen"
        }
    }

    nonisolated var systemImage: String {
        switch self {
        case .home:
            "house"
        case .capture:
            "plus.circle"
        case .history:
            "calendar"
        case .syncAndExport:
            "arrow.trianglehead.2.clockwise.icloud"
        case .settings:
            "gearshape"
        }
    }

    nonisolated var capabilities: Set<AppCapability> {
        switch self {
        case .home:
            [.todayFocus]
        case .capture:
            [.episodeCapture]
        case .history:
            [.historyReview]
        case .syncAndExport:
            [.syncManagement, .dataExport]
        case .settings:
            [.settings, .privacyInformation]
        }
    }

    nonisolated static let defaultTab: AppTab = .history

    init(capability: AppCapability) {
        switch capability {
        case .todayFocus:
            self = .home
        case .episodeCapture:
            self = .capture
        case .historyReview:
            self = .history
        case .syncManagement, .dataExport:
            self = .syncAndExport
        case .settings, .privacyInformation:
            self = .settings
        }
    }
}
