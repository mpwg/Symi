import Foundation

@MainActor
protocol EpisodeWeatherContextProviding: AnyObject {
    func loadWeather(
        for startedAt: Date,
        originalStartedAt: Date?,
        originalSnapshot: WeatherSnapshotData?
    ) async -> WeatherLoadState

    func snapshotForSave(
        startedAt: Date,
        currentState: WeatherLoadState,
        originalStartedAt: Date?,
        originalSnapshot: WeatherSnapshotData?
    ) async throws -> EpisodeWeatherSnapshotResolution
}

struct EpisodeWeatherSnapshotResolution: Equatable {
    let snapshot: WeatherSnapshotData?
    let state: WeatherLoadState
}

@MainActor
final class EpisodeWeatherContextService: EpisodeWeatherContextProviding {
    private let weatherService: any WeatherService
    private let locationService: any LocationService

    init(weatherService: any WeatherService, locationService: any LocationService) {
        self.weatherService = weatherService
        self.locationService = locationService
    }

    func loadWeather(
        for startedAt: Date,
        originalStartedAt: Date?,
        originalSnapshot: WeatherSnapshotData?
    ) async -> WeatherLoadState {
        await PerformanceInstrumentation.measure("EpisodeWeatherRefresh") {
            if AppStoreScreenshotMode.isEnabled {
                return .loaded(AppStoreScreenshotMode.sampleWeatherSnapshot(for: startedAt))
            }

            if startedAt > .now {
                return .unavailable("Für zukünftige Zeitpunkte wird kein Wetter geladen.")
            }

            if originalStartedAt == startedAt, let originalSnapshot {
                return .loaded(originalSnapshot)
            }

            do {
                let location = try await locationService.requestApproximateLocation()
                guard let snapshot = try await weatherService.fetchWeather(for: startedAt, location: location) else {
                    return .unavailable("Für diesen Zeitpunkt konnten keine Wetterdaten geladen werden.")
                }
                return .loaded(snapshot)
            } catch let error as EpisodeSaveError {
                return .unavailable(error.localizedDescription)
            } catch let error as any LocalizedError {
                return .unavailable(error.errorDescription ?? "Wetterdaten konnten nicht geladen werden.")
            } catch {
                return .unavailable("Wetterdaten konnten nicht geladen werden.")
            }
        }
    }

    func snapshotForSave(
        startedAt: Date,
        currentState: WeatherLoadState,
        originalStartedAt: Date?,
        originalSnapshot: WeatherSnapshotData?
    ) async throws -> EpisodeWeatherSnapshotResolution {
        if startedAt > .now {
            throw EpisodeSaveError.futureDate
        }

        if originalStartedAt == startedAt {
            return EpisodeWeatherSnapshotResolution(snapshot: originalSnapshot, state: originalSnapshot.map { .loaded($0) } ?? .idle)
        }

        if case .loaded(let snapshot) = currentState {
            return EpisodeWeatherSnapshotResolution(snapshot: snapshot, state: currentState)
        }

        let refreshedState = await loadWeather(
            for: startedAt,
            originalStartedAt: originalStartedAt,
            originalSnapshot: originalSnapshot
        )

        if case .loaded(let snapshot) = refreshedState {
            return EpisodeWeatherSnapshotResolution(snapshot: snapshot, state: refreshedState)
        }

        return EpisodeWeatherSnapshotResolution(snapshot: nil, state: refreshedState)
    }
}
