import Foundation

enum MacRoute: String, CaseIterable, Identifiable {
    case history
    case capture
    case sync
    case export

    nonisolated var id: String { rawValue }

    nonisolated var title: String {
        switch self {
        case .history:
            "Verlauf"
        case .capture:
            "Erfassen"
        case .sync:
            "Synchronisation"
        case .export:
            "Export"
        }
    }

    nonisolated var subtitle: String {
        switch self {
        case .history:
            "Kalender, Tageskontext und Episodendetails"
        case .capture:
            "Neue Episode mit Kontext und Medikamenten"
        case .sync:
            "iCloud-Status, Konflikte und Protokolle"
        case .export:
            "Berichte, Backups und Datenübernahme"
        }
    }

    nonisolated var systemImage: String {
        switch self {
        case .history:
            "calendar"
        case .capture:
            "square.and.pencil"
        case .sync:
            "arrow.trianglehead.2.clockwise.icloud"
        case .export:
            "square.and.arrow.up.on.square"
        }
    }

    nonisolated var capabilities: Set<AppCapability> {
        switch self {
        case .history:
            [.historyReview, .todayFocus]
        case .capture:
            [.episodeCapture]
        case .sync:
            [.syncManagement]
        case .export:
            [.dataExport]
        }
    }

    nonisolated static let defaultRoute: MacRoute = .history
}

enum MacSettingsPane: String, CaseIterable, Identifiable {
    case sync
    case privacy

    nonisolated var id: String { rawValue }

    nonisolated var title: String {
        switch self {
        case .sync:
            "Synchronisation"
        case .privacy:
            "Hinweise"
        }
    }

    nonisolated var systemImage: String {
        switch self {
        case .sync:
            "gearshape.2"
        case .privacy:
            "hand.raised"
        }
    }

    nonisolated var capabilities: Set<AppCapability> {
        switch self {
        case .sync:
            [.settings]
        case .privacy:
            [.privacyInformation]
        }
    }
}

enum MacWindowIdentifier {
    static let privacyInformation = "privacy-information"
}
