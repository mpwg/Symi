import Foundation
import Testing
@testable import MigraineTracker

struct AppCapabilityParityTests {
    @Test
    func allRequiredCapabilitiesRemainAvailableOnBothPlatforms() {
        for capability in AppCapability.allCases {
            #expect(capability.iOSAccess.isAvailable)
            #expect(capability.macOSAccess.isAvailable)
            #expect(capability.iOSAccess.unavailableReason == nil)
            #expect(capability.macOSAccess.unavailableReason == nil)
        }
    }

    @Test
    func iosTabsCoverAllCapabilities() {
        let coveredCapabilities = Set(AppTab.allCases.flatMap { $0.capabilities })
        #expect(coveredCapabilities == Set(AppCapability.allCases))
    }

    @Test
    func macRoutesAndSettingsCoverAllCapabilities() {
        let routeCapabilities = Set(MacRoute.allCases.flatMap { $0.capabilities })
        let settingsCapabilities = Set(MacSettingsPane.allCases.flatMap { $0.capabilities })
        let coveredCapabilities = routeCapabilities.union(settingsCapabilities)

        #expect(coveredCapabilities == Set(AppCapability.allCases))
    }

    @Test
    func nonPlatformSourcesAvoidUIKitAndAppKitImports() throws {
        let repositoryRoot = URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourcesRoot = repositoryRoot.appending(path: "MigraineTracker/Sources")
        let enumerator = FileManager.default.enumerator(
            at: sourcesRoot,
            includingPropertiesForKeys: nil
        )

        while let fileURL = enumerator?.nextObject() as? URL {
            guard fileURL.pathExtension == "swift" else {
                continue
            }

            let relativePath = fileURL.path.replacingOccurrences(
                of: sourcesRoot.path + "/",
                with: ""
            )

            guard !relativePath.hasPrefix("Platforms/") else {
                continue
            }

            let content = try String(contentsOf: fileURL)
            #expect(!content.contains("import UIKit"), "\(relativePath) importiert UIKit außerhalb von Platforms.")
            #expect(!content.contains("import AppKit"), "\(relativePath) importiert AppKit außerhalb von Platforms.")
        }
    }
}
