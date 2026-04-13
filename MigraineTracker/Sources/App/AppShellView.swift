import SwiftUI

struct AppShellView: View {
    let appContainer: AppContainer

    var body: some View {
        NavigationStack {
            HistoryView(appContainer: appContainer)
        }
    }
}

#Preview {
    Text("Preview nicht verfügbar")
}
