#if os(macOS)
import SwiftUI
import UniformTypeIdentifiers

struct MacExportWorkspaceView: View {
    let model: MacAppModel

    var body: some View {
        let exportController = model.exportController
        @Bindable var controller = exportController

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                MacSectionIntro(
                    eyebrow: "Export",
                    title: "Berichte und Backups als Dokumentenfluss",
                    detail: "Zeitraum, Vorschau und Dateiausgabe sind im Desktop-Kontext sichtbar, ohne Umwege durch Einstellungen."
                )

                MacSurfaceCard(title: "Zeitraum") {
                    HStack {
                        DatePicker("Von", selection: $controller.startDate, displayedComponents: .date)
                        DatePicker("Bis", selection: $controller.endDate, displayedComponents: .date)
                    }

                    Text("Episoden im Zeitraum: \(controller.summary.episodeCount)")
                        .font(.headline)

                    if controller.summary.episodeCount > 0 {
                        Text("Durchschnittliche Intensität: \(controller.summary.averageIntensity.formatted(.number.precision(.fractionLength(1))))/10")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Passe den Zeitraum an, damit eine Vorschau und ein PDF möglich werden.")
                            .foregroundStyle(.secondary)
                    }
                }

                MacSurfaceCard(title: "Vorschau", subtitle: "Die ersten Einträge des gewählten Zeitraums") {
                    if controller.summary.records.isEmpty {
                        ContentUnavailableView(
                            "Keine Episoden im Zeitraum",
                            systemImage: "square.and.arrow.up",
                            description: Text("Wähle einen anderen Zeitraum oder importiere zuerst vorhandene Daten.")
                        )
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(controller.summary.records.prefix(8)) { record in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(record.startedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.headline)
                                    Text("\(record.type) · Intensität \(record.intensity)/10")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    if !record.medications.isEmpty {
                                        Text(record.medications.map(\.name).joined(separator: ", "))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    if let weather = record.weather, !weather.condition.isEmpty {
                                        Text("Wetter: \(weather.condition)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.bottom, 4)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .onAppear {
            controller.reloadSummary()
        }
        .onChange(of: controller.startDate) { _, _ in
            controller.reloadSummary()
        }
        .onChange(of: controller.endDate) { _, _ in
            controller.reloadSummary()
        }
    }
}

struct MacExportInspectorView: View {
    @Bindable var controller: DataExportController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                MacSectionIntro(
                    eyebrow: "Inspector",
                    title: "Dateien und Ausgabe",
                    detail: "Exportstatus, Teilen und Import bleiben gesammelt an einer Stelle."
                )

                MacSurfaceCard(title: "Metriken") {
                    HStack(spacing: 12) {
                        MacMetricBadge(title: "Episoden", value: "\(controller.summary.episodeCount)", tint: .blue)
                        MacMetricBadge(
                            title: "Ø Intensität",
                            value: controller.summary.episodeCount == 0
                                ? "–"
                                : controller.summary.averageIntensity.formatted(.number.precision(.fractionLength(1))),
                            tint: .orange
                        )
                    }

                    MacInspectorFactRow(
                        title: "Zeitraum",
                        value: "\(controller.startDate.formatted(date: .abbreviated, time: .omitted)) – \(controller.endDate.formatted(date: .abbreviated, time: .omitted))"
                    )
                }

                MacSurfaceCard(title: "Aktionen") {
                    Button("PDF erstellen") {
                        controller.createPDF()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!controller.canExport)

                    Button("JSON5 erstellen") {
                        controller.createBackup()
                    }

                    Button("JSON5 importieren") {
                        controller.isImportingData = true
                    }
                }

                MacSurfaceCard(title: "Dateien") {
                    if let exportURL = controller.exportURL {
                        ShareLink(item: exportURL) {
                            Label("PDF teilen", systemImage: "square.and.arrow.up")
                        }
                    }

                    if let dataExportURL = controller.dataExportURL {
                        ShareLink(item: dataExportURL) {
                            Label("JSON5 teilen", systemImage: "square.and.arrow.up")
                        }
                    }

                    if let exportErrorMessage = controller.exportErrorMessage {
                        Text(exportErrorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }

                    if let dataTransferMessage = controller.dataTransferMessage {
                        Text(dataTransferMessage)
                            .font(.subheadline)
                            .foregroundStyle(dataTransferMessage.contains("Fehler") ? .red : .secondary)
                    }
                }
            }
            .padding(20)
        }
        .frame(minWidth: 320, idealWidth: 360, maxWidth: 420, maxHeight: .infinity, alignment: .topLeading)
        .fileImporter(
            isPresented: $controller.isImportingData,
            allowedContentTypes: [.migraineTrackerJSON5, .json, .plainText]
        ) { result in
            controller.importBackup(from: result)
        }
    }
}
#endif
