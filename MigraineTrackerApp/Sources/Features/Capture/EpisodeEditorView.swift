import SwiftData
import SwiftUI

struct EpisodeEditorView: View {
    private enum EditorMode {
        case create
        case edit
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let mode: EditorMode
    private let episode: Episode?
    private let onSaved: (() -> Void)?

    @State private var type: EpisodeType
    @State private var intensity: Double
    @State private var startedAt: Date
    @State private var endedAtEnabled: Bool
    @State private var endedAt: Date
    @State private var painLocation: String
    @State private var painCharacter: String
    @State private var notes: String
    @State private var functionalImpact: String
    @State private var menstruationStatus: MenstruationStatus
    @State private var selectedSymptoms: Set<String>
    @State private var selectedTriggers: Set<String>
    @State private var medications: [MedicationDraft]
    @State private var saveMessageVisible = false

    private let symptomOptions = ["Übelkeit", "Lichtempfindlichkeit", "Geräuschempfindlichkeit", "Aura"]
    private let triggerOptions = ["Stress", "Schlafmangel", "Alkohol", "Menstruation", "Bildschirmzeit"]

    init(episode: Episode? = nil, onSaved: (() -> Void)? = nil) {
        self.episode = episode
        self.onSaved = onSaved
        self.mode = episode == nil ? .create : .edit

        _type = State(initialValue: episode?.type ?? .unclear)
        _intensity = State(initialValue: Double(episode?.intensity ?? 5))
        _startedAt = State(initialValue: episode?.startedAt ?? .now)
        _endedAtEnabled = State(initialValue: episode?.endedAt != nil)
        _endedAt = State(initialValue: episode?.endedAt ?? .now)
        _painLocation = State(initialValue: episode?.painLocation ?? "")
        _painCharacter = State(initialValue: episode?.painCharacter ?? "")
        _notes = State(initialValue: episode?.notes ?? "")
        _functionalImpact = State(initialValue: episode?.functionalImpact ?? "")
        _menstruationStatus = State(initialValue: episode?.menstruationStatus ?? .unknown)
        _selectedSymptoms = State(initialValue: Set(episode?.symptoms ?? []))
        _selectedTriggers = State(initialValue: Set(episode?.triggers ?? []))
        _medications = State(initialValue: episode?.medications.map(MedicationDraft.init) ?? [MedicationDraft()])
    }

    var body: some View {
        Form {
            Section("Episode") {
                Picker("Typ", selection: $type) {
                    ForEach(EpisodeType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Intensität")
                    Slider(value: $intensity, in: 1 ... 10, step: 1)
                    Text("\(Int(intensity)) / 10")
                        .font(.headline)
                }

                DatePicker("Beginn", selection: $startedAt)
                Toggle("Ende angeben", isOn: $endedAtEnabled.animation())
                if endedAtEnabled {
                    DatePicker("Ende", selection: $endedAt, in: startedAt...)
                }
            }

            Section("Kontext") {
                TextField("Schmerzlokalisation", text: $painLocation)
                TextField("Schmerzcharakter", text: $painCharacter)
                TextField("Funktionelle Einschränkung", text: $functionalImpact)

                Picker("Menstruationsstatus", selection: $menstruationStatus) {
                    ForEach(MenstruationStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
            }

            selectionSection(title: "Symptome", options: symptomOptions, selection: $selectedSymptoms)
            selectionSection(title: "Trigger", options: triggerOptions, selection: $selectedTriggers)

            Section("Notiz") {
                TextField("Optionale Notiz", text: $notes, axis: .vertical)
                    .lineLimit(3 ... 6)
            }

            Section("Medikamente") {
                ForEach($medications) { $medication in
                    MedicationDraftForm(draft: $medication)
                }
                .onDelete { offsets in
                    medications.remove(atOffsets: offsets)
                    if medications.isEmpty {
                        medications = [MedicationDraft()]
                    }
                }

                Button {
                    medications.append(MedicationDraft())
                } label: {
                    Label("Medikament hinzufügen", systemImage: "plus.circle")
                }
            }
        }
        .navigationTitle(mode == .create ? "Erfassen" : "Episode bearbeiten")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(mode == .create ? "Speichern" : "Aktualisieren") {
                    saveEpisode()
                }
            }
        }
        .alert("Episode gespeichert", isPresented: $saveMessageVisible) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Die Episode wurde lokal in SwiftData gespeichert.")
        }
    }

    @ViewBuilder
    private func selectionSection(title: String, options: [String], selection: Binding<Set<String>>) -> some View {
        Section(title) {
            ForEach(options, id: \.self) { option in
                Toggle(
                    option,
                    isOn: Binding(
                        get: { selection.wrappedValue.contains(option) },
                        set: { isSelected in
                            if isSelected {
                                selection.wrappedValue.insert(option)
                            } else {
                                selection.wrappedValue.remove(option)
                            }
                        }
                    )
                )
            }
        }
    }

    private func saveEpisode() {
        let target = episode ?? Episode(startedAt: startedAt, intensity: Int(intensity))

        target.type = type
        target.startedAt = startedAt
        target.endedAt = endedAtEnabled ? endedAt : nil
        target.intensity = Int(intensity)
        target.painLocation = painLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        target.painCharacter = painCharacter.trimmingCharacters(in: .whitespacesAndNewlines)
        target.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        target.functionalImpact = functionalImpact.trimmingCharacters(in: .whitespacesAndNewlines)
        target.menstruationStatus = menstruationStatus
        target.symptoms = Array(selectedSymptoms).sorted()
        target.triggers = Array(selectedTriggers).sorted()

        let existingMedications = target.medications
        for medication in existingMedications {
            modelContext.delete(medication)
        }

        if episode == nil {
            modelContext.insert(target)
        }

        let validDrafts = medications.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        for draft in validDrafts {
            let entry = MedicationEntry(
                name: draft.name.trimmingCharacters(in: .whitespacesAndNewlines),
                category: draft.category,
                dosage: draft.dosage.trimmingCharacters(in: .whitespacesAndNewlines),
                takenAt: draft.takenAt,
                effectiveness: draft.effectiveness,
                reliefStartedAt: draft.reliefStartedAtEnabled ? draft.reliefStartedAt : nil,
                isRepeatDose: draft.isRepeatDose,
                episode: target
            )
            target.medications.append(entry)
        }

        do {
            try modelContext.save()

            if mode == .create {
                resetForm()
                saveMessageVisible = true
            } else {
                onSaved?()
                dismiss()
            }
        } catch {
            assertionFailure("Speichern fehlgeschlagen: \(error)")
        }
    }

    private func resetForm() {
        type = .unclear
        intensity = 5
        startedAt = .now
        endedAtEnabled = false
        endedAt = .now
        painLocation = ""
        painCharacter = ""
        notes = ""
        functionalImpact = ""
        menstruationStatus = .unknown
        selectedSymptoms = []
        selectedTriggers = []
        medications = [MedicationDraft()]
    }
}

private struct MedicationDraftForm: View {
    @Binding var draft: MedicationDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Name", text: $draft.name)
            Picker("Kategorie", selection: $draft.category) {
                ForEach(MedicationCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }

            TextField("Dosis", text: $draft.dosage)
            DatePicker("Einnahme", selection: $draft.takenAt)

            Picker("Wirkung", selection: $draft.effectiveness) {
                ForEach(MedicationEffectiveness.allCases) { effectiveness in
                    Text(effectiveness.rawValue).tag(effectiveness)
                }
            }

            Toggle("Wiederholungseinnahme", isOn: $draft.isRepeatDose)
            Toggle("Wirkungseintritt angeben", isOn: $draft.reliefStartedAtEnabled.animation())
            if draft.reliefStartedAtEnabled {
                DatePicker("Wirkungseintritt", selection: $draft.reliefStartedAt)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct MedicationDraft: Identifiable {
    let id: UUID
    var name: String
    var category: MedicationCategory
    var dosage: String
    var takenAt: Date
    var effectiveness: MedicationEffectiveness
    var reliefStartedAtEnabled: Bool
    var reliefStartedAt: Date
    var isRepeatDose: Bool

    init(
        id: UUID = UUID(),
        name: String = "",
        category: MedicationCategory = .other,
        dosage: String = "",
        takenAt: Date = .now,
        effectiveness: MedicationEffectiveness = .partial,
        reliefStartedAtEnabled: Bool = false,
        reliefStartedAt: Date = .now,
        isRepeatDose: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.dosage = dosage
        self.takenAt = takenAt
        self.effectiveness = effectiveness
        self.reliefStartedAtEnabled = reliefStartedAtEnabled
        self.reliefStartedAt = reliefStartedAt
        self.isRepeatDose = isRepeatDose
    }

    init(entry: MedicationEntry) {
        self.id = entry.id
        self.name = entry.name
        self.category = entry.category
        self.dosage = entry.dosage
        self.takenAt = entry.takenAt
        self.effectiveness = entry.effectiveness
        self.reliefStartedAtEnabled = entry.reliefStartedAt != nil
        self.reliefStartedAt = entry.reliefStartedAt ?? entry.takenAt
        self.isRepeatDose = entry.isRepeatDose
    }
}

#Preview {
    NavigationStack {
        EpisodeEditorView()
    }
}
