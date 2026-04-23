import XCTest

@MainActor
final class MigraineTrackerScreenshotTests: XCTestCase {
    private struct Screen {
        let route: String
        let snapshotName: String
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCaptureMainStoreScreens() throws {
        let screens: [Screen] = [
            .init(route: "home", snapshotName: "01-home"),
            .init(route: "new-entry", snapshotName: "02-new-entry"),
            .init(route: "history", snapshotName: "03-diary"),
            .init(route: "episode-detail", snapshotName: "04-entry-detail"),
            .init(route: "export", snapshotName: "05-export"),
            .init(route: "doctors", snapshotName: "06-doctors"),
            .init(route: "doctor-detail", snapshotName: "07-doctor-detail"),
            .init(route: "doctor-add", snapshotName: "08-add-doctor"),
            .init(route: "appointment-flow", snapshotName: "09-appointment-flow"),
            .init(route: "privacy-info", snapshotName: "10-privacy")
        ]

        for screen in screens {
            let app = XCUIApplication()
            setupSnapshot(app, waitForAnimations: false)
            app.launchArguments += [
                "-mt_screenshot_screen",
                screen.route,
                "-mt_screenshot_seed",
                "default"
            ]
            app.launch()
            waitForStableLayout()
            snapshot(screen.snapshotName, waitForLoadingIndicator: false)
            app.terminate()
        }
        assert(true)
    }

    private func waitForStableLayout() {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.2))
    }
}
