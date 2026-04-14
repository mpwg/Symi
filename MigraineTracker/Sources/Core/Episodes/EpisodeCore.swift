import Foundation
import Observation

struct WeatherRecord: Equatable, Sendable {
    let recordedAt: Date
    let condition: String
    let temperature: Double?
    let humidity: Double?
    let pressure: Double?
    let source: String
}

struct MedicationRecord: Identifiable, Equatable, Sendable {
    let id: UUID
    let name: String
    let category: MedicationCategory
    let dosage: String
    let quantity: Int
    let takenAt: Date
    let effectiveness: MedicationEffectiveness
    let reliefStartedAt: Date?
    let isRepeatDose: Bool
}

struct EpisodeRecord: Identifiable, Equatable, Sendable {
    let id: UUID
    let startedAt: Date
    let endedAt: Date?
    let updatedAt: Date
    let deletedAt: Date?
    let type: EpisodeType
    let intensity: Int
    let painLocation: String
    let painCharacter: String
    let notes: String
    let symptoms: [String]
    let triggers: [String]
    let functionalImpact: String
    let menstruationStatus: MenstruationStatus
    let medications: [MedicationRecord]
    let weather: WeatherRecord?

    var isDeleted: Bool {
        deletedAt != nil
    }
}

struct MedicationDefinitionRecord: Identifiable, Equatable, Sendable {
    let id: String
    let catalogKey: String
    let groupID: String
    let groupTitle: String
    let groupFooter: String?
    let name: String
    let category: MedicationCategory
    let suggestedDosage: String
    let sortOrder: Int
    let isCustom: Bool
    let isDeleted: Bool

    init(
        catalogKey: String,
        groupID: String,
        groupTitle: String,
        groupFooter: String?,
        name: String,
        category: MedicationCategory,
        suggestedDosage: String,
        sortOrder: Int,
        isCustom: Bool,
        isDeleted: Bool
    ) {
        self.id = catalogKey
        self.catalogKey = catalogKey
        self.groupID = groupID
        self.groupTitle = groupTitle
        self.groupFooter = groupFooter
        self.name = name
        self.category = category
        self.suggestedDosage = suggestedDosage
        self.sortOrder = sortOrder
        self.isCustom = isCustom
        self.isDeleted = isDeleted
    }

    var selectionKey: String {
        [
            name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            category.rawValue,
            suggestedDosage.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        ].joined(separator: "|")
    }
}

struct MedicationSelectionDraft: Identifiable, Equatable, Sendable {
    let id: UUID
    var selectionKey: String
    var name: String
    var category: MedicationCategory
    var dosage: String
    var quantity: Int
    var isSelected: Bool

    init(
        id: UUID = UUID(),
        selectionKey: String,
        name: String,
        category: MedicationCategory,
        dosage: String,
        quantity: Int = 1,
        isSelected: Bool = true
    ) {
        self.id = id
        self.selectionKey = selectionKey
        self.name = name
        self.category = category
        self.dosage = dosage
        self.quantity = max(1, quantity)
        self.isSelected = isSelected
    }

    init(record: MedicationRecord) {
        self.init(
            id: record.id,
            selectionKey: Self.makeSelectionKey(
                name: record.name,
                category: record.category,
                dosage: record.dosage
            ),
            name: record.name,
            category: record.category,
            dosage: record.dosage,
            quantity: record.quantity
        )
    }

    init(definition: MedicationDefinitionRecord) {
        self.init(
            selectionKey: definition.selectionKey,
            name: definition.name,
            category: definition.category,
            dosage: definition.suggestedDosage
        )
    }

    static func makeSelectionKey(name: String, category: MedicationCategory, dosage: String) -> String {
        [
            name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            category.rawValue,
            dosage.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        ].joined(separator: "|")
    }
}

struct WeatherInputDraft: Equatable, Sendable {
    var isEnabled: Bool
    var condition: String
    var temperatureText: String
    var humidityText: String
    var pressureText: String
    var source: String
}

struct EpisodeDraft: Equatable, Sendable {
    var id: UUID?
    var type: EpisodeType
    var intensity: Int
    var startedAt: Date
    var endedAtEnabled: Bool
    var endedAt: Date
    var painLocation: String
    var painCharacter: String
    var notes: String
    var functionalImpact: String
    var menstruationStatus: MenstruationStatus
    var selectedSymptoms: Set<String>
    var selectedTriggers: Set<String>
    var medications: [MedicationSelectionDraft]
    var weather: WeatherInputDraft

    static func makeNew(initialStartedAt: Date? = nil) -> EpisodeDraft {
        let startedAt = initialStartedAt ?? .now
        return EpisodeDraft(
            id: nil,
            type: .unclear,
            intensity: 5,
            startedAt: startedAt,
            endedAtEnabled: false,
            endedAt: startedAt,
            painLocation: "",
            painCharacter: "",
            notes: "",
            functionalImpact: "",
            menstruationStatus: .unknown,
            selectedSymptoms: [],
            selectedTriggers: [],
            medications: [],
            weather: WeatherInputDraft(
                isEnabled: false,
                condition: "",
                temperatureText: "",
                humidityText: "",
                pressureText: "",
                source: ""
            )
        )
    }

    static func from(record: EpisodeRecord) -> EpisodeDraft {
        EpisodeDraft(
            id: record.id,
            type: record.type,
            intensity: record.intensity,
            startedAt: record.startedAt,
            endedAtEnabled: record.endedAt != nil,
            endedAt: record.endedAt ?? record.startedAt,
            painLocation: record.painLocation,
            painCharacter: record.painCharacter,
            notes: record.notes,
            functionalImpact: record.functionalImpact,
            menstruationStatus: record.menstruationStatus,
            selectedSymptoms: Set(record.symptoms),
            selectedTriggers: Set(record.triggers),
            medications: record.medications.map(MedicationSelectionDraft.init(record:)),
            weather: WeatherInputDraft(
                isEnabled: record.weather != nil,
                condition: record.weather?.condition ?? "",
                temperatureText: Self.stringValue(for: record.weather?.temperature, fractionDigits: 1),
                humidityText: Self.stringValue(for: record.weather?.humidity, fractionDigits: 0),
                pressureText: Self.stringValue(for: record.weather?.pressure, fractionDigits: 0),
                source: record.weather?.source ?? ""
            )
        )
    }

    private static func stringValue(for value: Double?, fractionDigits: Int) -> String {
        guard let value else {
            return ""
        }

        return value.formatted(.number.precision(.fractionLength(fractionDigits)))
    }
}

struct CustomMedicationDefinitionDraft: Equatable, Sendable {
    let id: String
    let originalSelectionKey: String?
    let name: String
    let category: MedicationCategory
    let dosage: String
}

struct EpisodeEditorMedicationGroup: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let footer: String?
    let items: [MedicationDefinitionRecord]
}

protocol EpisodeRepository {
    func fetchRecent() throws -> [EpisodeRecord]
    func fetchByDay(_ day: Date) throws -> [EpisodeRecord]
    func fetchByMonth(_ month: Date) throws -> [EpisodeRecord]
    func load(id: UUID) throws -> EpisodeRecord?
    @discardableResult
    func save(draft: EpisodeDraft, validatedWeather: ValidatedWeatherSnapshot?) throws -> UUID
    func softDelete(id: UUID) throws
    func restore(id: UUID) throws
    func fetchDeleted() throws -> [EpisodeRecord]
}

protocol MedicationCatalogRepository {
    func fetchDefinitions(searchText: String?) throws -> [MedicationDefinitionRecord]
    func saveCustomDefinition(_ draft: CustomMedicationDefinitionDraft) throws -> MedicationDefinitionRecord
    func softDeleteCustomDefinition(catalogKey: String) throws
    func fetchDeletedDefinitions() throws -> [MedicationDefinitionRecord]
}

struct SaveEpisodeUseCase {
    let repository: EpisodeRepository

    @discardableResult
    func execute(_ draft: EpisodeDraft) throws -> UUID {
        if draft.endedAtEnabled, draft.endedAt < draft.startedAt {
            throw EpisodeSaveError.invalidDateRange
        }

        let validatedWeather = try WeatherInputValidator.validate(
            isEnabled: draft.weather.isEnabled,
            condition: draft.weather.condition,
            temperatureText: draft.weather.temperatureText,
            humidityText: draft.weather.humidityText,
            pressureText: draft.weather.pressureText,
            source: draft.weather.source
        )

        return try repository.save(draft: draft, validatedWeather: validatedWeather)
    }
}

struct HomeOverviewData: Equatable {
    let latestEpisode: EpisodeRecord?
    let episodeCount: Int
}

struct LoadHomeOverviewUseCase {
    let repository: EpisodeRepository

    func execute() throws -> HomeOverviewData {
        let episodes = try repository.fetchRecent()
        return HomeOverviewData(
            latestEpisode: episodes.first,
            episodeCount: episodes.count
        )
    }
}

enum EpisodeSaveError: LocalizedError {
    case invalidDateRange

    var errorDescription: String? {
        switch self {
        case .invalidDateRange:
            "Das Ende darf nicht vor dem Beginn liegen."
        }
    }
}

@MainActor
@Observable
final class EpisodeEditorController {
    let mode: EpisodeEditorMode
    let symptomOptions = [
        "Übelkeit",
        "Lichtempfindlichkeit",
        "Geräuschempfindlichkeit",
        "Aura",
        "Kiefer-/Aufbissschmerz",
        "Pochen, Pulsieren"
    ]
    let triggerOptions = ["Stress", "Schlafmangel", "Alkohol", "Menstruation", "Bildschirmzeit"]
    let weatherConditionOptions = ["Wetterumschwung/Wind"]

    var draft: EpisodeDraft
    var medicationSearchText = ""
    var saveMessageVisible = false
    var validationMessage: String?
    var customMedicationEditor: CustomMedicationEditorSheetState?
    var pendingMedicationDeletion: MedicationDefinitionRecord?
    private(set) var medicationDefinitions: [MedicationDefinitionRecord] = []

    private let saveEpisodeUseCase: SaveEpisodeUseCase
    private let episodeRepository: EpisodeRepository
    private let medicationRepository: MedicationCatalogRepository

    init(
        episodeID: UUID?,
        initialStartedAt: Date?,
        episodeRepository: EpisodeRepository,
        medicationRepository: MedicationCatalogRepository
    ) {
        self.episodeRepository = episodeRepository
        self.medicationRepository = medicationRepository
        self.saveEpisodeUseCase = SaveEpisodeUseCase(repository: episodeRepository)

        if
            let episodeID,
            let record = try? episodeRepository.load(id: episodeID)
        {
            self.mode = .edit
            self.draft = EpisodeDraft.from(record: record)
        } else {
            self.mode = .create
            self.draft = EpisodeDraft.makeNew(initialStartedAt: initialStartedAt)
        }

        reloadMedicationDefinitions()
    }

    var filteredMedicationGroups: [EpisodeEditorMedicationGroup] {
        let query = medicationSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let groups = allMedicationGroups

        guard !query.isEmpty else {
            return groups
        }

        return groups.compactMap { group in
            let items = group.items.filter { $0.name.localizedCaseInsensitiveContains(query) }
            guard !items.isEmpty else {
                return nil
            }

            return EpisodeEditorMedicationGroup(
                id: group.id,
                title: group.title,
                footer: group.footer,
                items: items
            )
        }
    }

    var selectedMedications: [MedicationSelectionDraft] {
        draft.medications
            .filter(\.isSelected)
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func reloadMedicationDefinitions() {
        medicationDefinitions = (try? medicationRepository.fetchDefinitions(searchText: nil)) ?? []
    }

    func save(onSaved: (() -> Void)?, onDismiss: () -> Void) {
        validationMessage = nil

        do {
            try saveEpisodeUseCase.execute(draft)
            reloadMedicationDefinitions()
            validationMessage = nil

            if mode == .create, onSaved == nil {
                draft = EpisodeDraft.makeNew()
                medicationSearchText = ""
                customMedicationEditor = nil
                pendingMedicationDeletion = nil
                saveMessageVisible = true
            } else {
                onSaved?()
                onDismiss()
            }
        } catch {
            validationMessage = error.localizedDescription
        }
    }

    func isMedicationSelected(_ definition: MedicationDefinitionRecord) -> Bool {
        draft.medications.contains { $0.selectionKey == definition.selectionKey && $0.isSelected }
    }

    func quantity(for definition: MedicationDefinitionRecord) -> Int {
        draft.medications.first(where: { $0.selectionKey == definition.selectionKey })?.quantity ?? 1
    }

    func toggleMedicationSelection(for definition: MedicationDefinitionRecord) {
        if let index = draft.medications.firstIndex(where: { $0.selectionKey == definition.selectionKey }) {
            draft.medications[index].isSelected.toggle()
            draft.medications[index].quantity = max(1, draft.medications[index].quantity)
        } else {
            draft.medications.append(MedicationSelectionDraft(definition: definition))
        }
    }

    func incrementMedicationQuantity(for definition: MedicationDefinitionRecord) {
        if let index = draft.medications.firstIndex(where: { $0.selectionKey == definition.selectionKey }) {
            draft.medications[index].quantity += 1
            draft.medications[index].isSelected = true
        } else {
            draft.medications.append(MedicationSelectionDraft(definition: definition))
        }
    }

    func decrementMedicationQuantity(for definition: MedicationDefinitionRecord) {
        guard let index = draft.medications.firstIndex(where: { $0.selectionKey == definition.selectionKey }) else {
            return
        }

        draft.medications[index].quantity = max(1, draft.medications[index].quantity - 1)
        draft.medications[index].isSelected = true
    }

    func removeMedicationSelection(id: UUID) {
        guard let index = draft.medications.firstIndex(where: { $0.id == id }) else {
            return
        }

        draft.medications[index].isSelected = false
        draft.medications[index].quantity = 1
    }

    func presentEditor(for definition: MedicationDefinitionRecord?) {
        customMedicationEditor = CustomMedicationEditorSheetState(definition: definition)
    }

    func saveCustomMedication(from draft: CustomMedicationDefinitionDraft) {
        let trimmedName = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            validationMessage = "Bitte gib einen Namen für das eigene Medikament ein."
            return
        }

        if let existing = medicationDefinitions.first(where: {
            $0.catalogKey != draft.id &&
            $0.name.compare(trimmedName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }) {
            toggleMedicationSelection(for: existing)
            customMedicationEditor = nil
            validationMessage = nil
            return
        }

        do {
            let definition = try medicationRepository.saveCustomDefinition(draft)
            reloadMedicationDefinitions()
            customMedicationEditor = nil
            validationMessage = nil

            if let existingSelectionKey = draft.originalSelectionKey {
                updateMedicationSelection(from: existingSelectionKey, to: definition)
            } else {
                toggleMedicationSelection(for: definition)
            }
        } catch {
            validationMessage = "Eigenes Medikament konnte nicht gespeichert werden."
        }
    }

    func deleteCustomMedication(_ definition: MedicationDefinitionRecord) {
        do {
            draft.medications.removeAll { $0.selectionKey == definition.selectionKey }
            try medicationRepository.softDeleteCustomDefinition(catalogKey: definition.catalogKey)
            reloadMedicationDefinitions()
            pendingMedicationDeletion = nil
            validationMessage = nil
        } catch {
            validationMessage = "Eigenes Medikament konnte nicht gelöscht werden."
        }
    }

    private var allMedicationGroups: [EpisodeEditorMedicationGroup] {
        let knownKeys = Set(medicationDefinitions.map(\.selectionKey))
        let persistedGroups = Dictionary(grouping: medicationDefinitions) { $0.groupID }
        let sortedGroupIDs = persistedGroups.keys.sorted { lhs, rhs in
            let leftOrder = persistedGroups[lhs]?.map(\.sortOrder).min() ?? .max
            let rightOrder = persistedGroups[rhs]?.map(\.sortOrder).min() ?? .max
            return leftOrder < rightOrder
        }

        var groups = sortedGroupIDs.compactMap { groupID -> EpisodeEditorMedicationGroup? in
            guard let items = persistedGroups[groupID], let first = items.first else {
                return nil
            }

            return EpisodeEditorMedicationGroup(
                id: groupID,
                title: first.groupTitle,
                footer: first.groupFooter,
                items: items.sorted { $0.sortOrder < $1.sortOrder }
            )
        }

        let orphanSelections = draft.medications.compactMap { selection -> MedicationDefinitionRecord? in
            guard !knownKeys.contains(selection.selectionKey) else {
                return nil
            }

            return MedicationDefinitionRecord(
                catalogKey: "selection:\(selection.selectionKey)",
                groupID: "custom-medications",
                groupTitle: "Eigene Medikamente",
                groupFooter: "Eigene Medikamente werden lokal in SwiftData gespeichert und bleiben in deiner persönlichen Auswahlliste verfügbar.",
                name: selection.name,
                category: selection.category,
                suggestedDosage: selection.dosage,
                sortOrder: Int.max - 1,
                isCustom: true,
                isDeleted: false
            )
        }

        if !orphanSelections.isEmpty {
            groups.removeAll { $0.id == "custom-medications" }
            let customItems = (persistedGroups["custom-medications"] ?? []) + orphanSelections
            let deduped = Dictionary(uniqueKeysWithValues: customItems.map { ($0.selectionKey, $0) }).values
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

            groups.append(
                EpisodeEditorMedicationGroup(
                    id: "custom-medications",
                    title: "Eigene Medikamente",
                    footer: "Eigene Medikamente werden lokal in SwiftData gespeichert und bleiben in deiner persönlichen Auswahlliste verfügbar.",
                    items: deduped
                )
            )
        }

        return groups
    }

    private func updateMedicationSelection(from oldSelectionKey: String, to definition: MedicationDefinitionRecord) {
        guard let index = draft.medications.firstIndex(where: { $0.selectionKey == oldSelectionKey }) else {
            return
        }

        draft.medications[index].selectionKey = definition.selectionKey
        draft.medications[index].name = definition.name
        draft.medications[index].category = definition.category
        draft.medications[index].dosage = definition.suggestedDosage
        draft.medications[index].isSelected = true
    }
}

enum EpisodeEditorMode {
    case create
    case edit
}

struct CustomMedicationEditorSheetState: Identifiable, Equatable {
    let id: String
    let originalSelectionKey: String?
    let initialName: String
    let initialCategory: MedicationCategory
    let initialDosage: String

    init(definition: MedicationDefinitionRecord?) {
        id = definition?.catalogKey ?? UUID().uuidString
        originalSelectionKey = definition?.selectionKey
        initialName = definition?.name ?? ""
        initialCategory = definition?.category ?? .other
        initialDosage = definition?.suggestedDosage ?? ""
    }

    var isEditing: Bool {
        originalSelectionKey != nil
    }
}
