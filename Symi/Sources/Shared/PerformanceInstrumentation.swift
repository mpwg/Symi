import Foundation
import OSLog

enum PerformanceInstrumentation {
    nonisolated private static let signposter = OSSignposter(subsystem: "Symi", category: "Performance")

    @discardableResult
    nonisolated static func measure<T>(_ name: StaticString, operation: () throws -> T) rethrows -> T {
        let state = signposter.beginInterval(name)
        defer { signposter.endInterval(name, state) }
        return try operation()
    }

    @discardableResult
    nonisolated static func measure<T>(_ name: StaticString, operation: () async throws -> T) async rethrows -> T {
        let state = signposter.beginInterval(name)
        defer { signposter.endInterval(name, state) }
        return try await operation()
    }
}
