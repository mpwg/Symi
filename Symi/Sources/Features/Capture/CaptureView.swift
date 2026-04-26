import SwiftUI

struct CaptureView: View {
    let appContainer: AppContainer

    var body: some View {
        EntryFlowCoordinatorView(appContainer: appContainer)
    }
}

#Preview {
    Text("Preview nicht verfügbar")
}
