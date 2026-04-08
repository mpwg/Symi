import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Episode.startedAt, order: .reverse)]) private var episodes: [Episode]

    var body: some View {
        List {
            if episodes.isEmpty {
                Section("Verlauf") {
                    Text("Noch keine Episoden gespeichert.")
                    Text("Lege zuerst eine Episode an, um den Verlauf aufzubauen.")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section("Verlauf") {
                    ForEach(episodes) { episode in
                        NavigationLink {
                            EpisodeDetailView(episode: episode)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(episode.startedAt, style: .date)
                                    .font(.headline)
                                Text("\(episode.type.rawValue) · Intensität \(episode.intensity)/10")
                                    .foregroundStyle(.secondary)
                                if !episode.medications.isEmpty {
                                    Text("\(episode.medications.count) Medikament(e)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .onDelete(perform: deleteEpisodes)
                }
            }
        }
        .navigationTitle("Verlauf")
    }

    private func deleteEpisodes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(episodes[index])
        }

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Löschen fehlgeschlagen: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
