#if os(macOS)
import SwiftUI

struct MacAppCommands: Commands {
    let model: MacAppModel

    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandMenu("Migraine Tracker") {
            Button("Neue Episode") {
                model.startNewEpisode()
            }
            .keyboardShortcut("n", modifiers: [.command])

            Button("Heute") {
                model.focusToday()
            }
            .keyboardShortcut("0", modifiers: [.command])
        }

        SidebarCommands()

        CommandGroup(after: .sidebar) {
            Button(model.showsInspector ? "Inspector ausblenden" : "Inspector einblenden") {
                model.toggleInspector()
            }
            .keyboardShortcut("i", modifiers: [.command, .control])
        }

        CommandGroup(after: .appInfo) {
            Button("Datenschutz und Hinweise") {
                openWindow(id: MacWindowIdentifier.privacyInformation)
            }
        }

        CommandGroup(after: .help) {
            Button("Datenschutz und Hinweise") {
                openWindow(id: MacWindowIdentifier.privacyInformation)
            }
        }
    }
}
#endif
