import Foundation

enum CapabilityAccess: Equatable {
    case primaryNavigation
    case secondaryNavigation
    case settingsScene
    case contextual
    case unavailable(reason: String)

    nonisolated var isAvailable: Bool {
        if case .unavailable = self {
            return false
        }

        return true
    }

    nonisolated var unavailableReason: String? {
        guard case .unavailable(let reason) = self else {
            return nil
        }

        return reason
    }
}

enum AppCapability: String, CaseIterable, Identifiable {
    case todayFocus
    case episodeCapture
    case historyReview
    case syncManagement
    case dataExport
    case settings
    case privacyInformation

    nonisolated var id: String { rawValue }

    nonisolated var title: String {
        switch self {
        case .todayFocus:
            "Heute"
        case .episodeCapture:
            "Erfassen"
        case .historyReview:
            "Verlauf"
        case .syncManagement:
            "Synchronisation"
        case .dataExport:
            "Export"
        case .settings:
            "Einstellungen"
        case .privacyInformation:
            "Datenschutz und Hinweise"
        }
    }

    nonisolated var iOSAccess: CapabilityAccess {
        switch self {
        case .todayFocus, .episodeCapture, .historyReview, .syncManagement, .dataExport, .settings:
            .primaryNavigation
        case .privacyInformation:
            .secondaryNavigation
        }
    }

    nonisolated var macOSAccess: CapabilityAccess {
        switch self {
        case .episodeCapture, .historyReview, .syncManagement, .dataExport:
            .primaryNavigation
        case .todayFocus:
            .contextual
        case .settings, .privacyInformation:
            .settingsScene
        }
    }
}
