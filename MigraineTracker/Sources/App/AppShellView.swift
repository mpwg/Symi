import SwiftUI

struct AppShellView: View {
    let appContainer: AppContainer
    #if os(macOS)
    let macAppModel: MacAppModel
    #endif

    var body: some View {
        #if os(macOS)
        MacAppShellView(model: macAppModel)
        #else
        IOSAppShellView(appContainer: appContainer)
        #endif
    }
}

#Preview {
    Text("Preview nicht verfügbar")
}
