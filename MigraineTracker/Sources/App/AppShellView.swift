import SwiftUI

struct AppShellView: View {
    let appContainer: AppContainer
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(appContainer: appContainer, selectedTab: $selectedTab)
            }
            .tabItem {
                Label(AppTab.home.title, systemImage: AppTab.home.systemImage)
            }
            .tag(AppTab.home)

            NavigationStack {
                CaptureView(appContainer: appContainer)
            }
            .tabItem {
                Label(AppTab.capture.title, systemImage: AppTab.capture.systemImage)
            }
            .tag(AppTab.capture)

            NavigationStack {
                HistoryView(appContainer: appContainer)
            }
            .tabItem {
                Label(AppTab.history.title, systemImage: AppTab.history.systemImage)
            }
            .tag(AppTab.history)

            NavigationStack {
                DoctorsHubView(appContainer: appContainer)
            }
            .tabItem {
                Label(AppTab.doctors.title, systemImage: AppTab.doctors.systemImage)
            }
            .tag(AppTab.doctors)

            NavigationStack {
                SettingsView(appContainer: appContainer)
            }
            .tabItem {
                Label(AppTab.export.title, systemImage: AppTab.export.systemImage)
            }
            .tag(AppTab.export)
        }
        .task {
            await appContainer.weatherBackfillService.runIfNeeded()
        }
    }
}

#Preview {
    Text("Preview nicht verfügbar")
}
