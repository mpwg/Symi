import SwiftUI

struct EpisodeDetailView: View {
    let episode: Episode
    @State private var isEditing = false

    var body: some View {
        List {
            Section("Episode") {
                detailRow("Typ", episode.type.rawValue)
                detailRow("Intensität", "\(episode.intensity) / 10")
                detailRow("Beginn", episode.startedAt.formatted(date: .abbreviated, time: .shortened))
                if let endedAt = episode.endedAt {
                    detailRow("Ende", endedAt.formatted(date: .abbreviated, time: .shortened))
                }
                if !episode.painLocation.isEmpty {
                    detailRow("Lokalisation", episode.painLocation)
                }
                if !episode.painCharacter.isEmpty {
                    detailRow("Charakter", episode.painCharacter)
                }
            }

            if !episode.symptoms.isEmpty {
                Section("Symptome") {
                    ForEach(episode.symptoms, id: \.self) { symptom in
                        Text(symptom)
                    }
                }
            }

            if !episode.triggers.isEmpty {
                Section("Trigger") {
                    ForEach(episode.triggers, id: \.self) { trigger in
                        Text(trigger)
                    }
                }
            }

            if !episode.medications.isEmpty {
                Section("Medikamente") {
                    ForEach(episode.medications) { medication in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(medication.name)
                                .font(.headline)
                            Text("\(medication.category.rawValue) · \(medication.dosage)")
                                .foregroundStyle(.secondary)
                            Text("Wirkung: \(medication.effectiveness.rawValue)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            if !episode.notes.isEmpty {
                Section("Notiz") {
                    Text(episode.notes)
                }
            }
        }
        .navigationTitle("Episodendetail")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Bearbeiten") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                EpisodeEditorView(episode: episode)
            }
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}
