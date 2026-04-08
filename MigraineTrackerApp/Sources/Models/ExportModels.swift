import Foundation

struct EpisodeExportRecord: Identifiable {
    let id: UUID
    let startedAt: Date
    let endedAt: Date?
    let type: String
    let intensity: Int
    let symptoms: [String]
    let triggers: [String]
    let notes: String
    let medications: [MedicationLine]

    init(episode: Episode) {
        self.id = episode.id
        self.startedAt = episode.startedAt
        self.endedAt = episode.endedAt
        self.type = episode.type.rawValue
        self.intensity = episode.intensity
        self.symptoms = episode.symptoms
        self.triggers = episode.triggers
        self.notes = episode.notes
        self.medications = episode.medications.map {
            MedicationLine(
                name: $0.name,
                category: $0.category.rawValue,
                dosage: $0.dosage,
                effectiveness: $0.effectiveness.rawValue
            )
        }
    }

    struct MedicationLine: Identifiable {
        let id = UUID()
        let name: String
        let category: String
        let dosage: String
        let effectiveness: String
    }
}

struct ExportPeriodSummary {
    let startDate: Date
    let endDate: Date
    let records: [EpisodeExportRecord]

    var episodeCount: Int { records.count }
}
