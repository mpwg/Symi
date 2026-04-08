import SwiftData
import SwiftUI

struct ExportView: View {
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -30, to: .now) ?? .now
    @State private var endDate = Date()
    @Query(sort: [SortDescriptor(\Episode.startedAt, order: .reverse)]) private var episodes: [Episode]

    var body: some View {
        let summary = exportSummary

        Form {
            Section("Zeitraum") {
                DatePicker("Von", selection: $startDate, displayedComponents: .date)
                DatePicker("Bis", selection: $endDate, displayedComponents: .date)
            }

            Section("Bericht") {
                Text("Episoden im Zeitraum: \(summary.episodeCount)")
                    .font(.headline)
                Text("Der PDF-Export wird lokal erzeugt und später über das iOS-Share-Sheet geteilt.")
                    .foregroundStyle(.secondary)
            }

            if !summary.records.isEmpty {
                Section("Vorschau") {
                    ForEach(summary.records.prefix(5)) { record in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.startedAt, style: .date)
                                .font(.headline)
                            Text("\(record.type) · Intensität \(record.intensity)/10")
                                .foregroundStyle(.secondary)
                            if !record.medications.isEmpty {
                                Text(record.medications.map(\.name).joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle("Export")
    }

    private var exportSummary: ExportPeriodSummary {
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        let filtered = episodes
            .filter { $0.startedAt >= startDate && $0.startedAt <= endOfDay }
            .map(EpisodeExportRecord.init)

        return ExportPeriodSummary(startDate: startDate, endDate: endDate, records: filtered)
    }
}

#Preview {
    NavigationStack {
        ExportView()
    }
}
