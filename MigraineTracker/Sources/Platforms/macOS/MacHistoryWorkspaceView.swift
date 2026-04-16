#if os(macOS)
import SwiftUI

struct MacHistoryWorkspaceView: View {
    let model: MacAppModel

    var body: some View {
        let controller = model.historyController

        HSplitView {
            VStack(alignment: .leading, spacing: 20) {
                MacSectionIntro(
                    eyebrow: "Verlauf",
                    title: "Tagesbuch statt Kartenstapel",
                    detail: "Kalender und Tageskontext bleiben links im Blick, Episoden öffnen sich im Inspector als ruhiger Arbeitsfluss."
                )

                MacSurfaceCard(
                    title: controller.displayedMonth.formatted(.dateTime.month(.wide).year()),
                    subtitle: "Wähle einen Tag oder springe direkt zu heute."
                ) {
                    HStack {
                        Button {
                            controller.goToPreviousMonth()
                            model.refreshHistorySelection()
                        } label: {
                            Label("Vorheriger Monat", systemImage: "chevron.left")
                        }
                        .buttonStyle(.borderless)

                        Spacer()

                        Button("Heute") {
                            model.focusToday()
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        Button {
                            controller.goToNextMonth()
                            model.refreshHistorySelection()
                        } label: {
                            Label("Nächster Monat", systemImage: "chevron.right")
                        }
                        .buttonStyle(.borderless)
                    }

                    MacHistoryMonthGrid(
                        month: controller.displayedMonth,
                        selectedDay: controller.selectedDay,
                        episodesByDay: controller.episodesByDay,
                        onSelectDay: model.selectHistoryDay
                    )
                }

                MacSurfaceCard(title: "Tageszusammenfassung") {
                    HStack(spacing: 12) {
                        MacMetricBadge(
                            title: "Episoden",
                            value: "\(controller.daySummary.episodeCount)",
                            tint: .blue
                        )

                        MacMetricBadge(
                            title: "Spitze",
                            value: controller.daySummary.episodeCount == 0 ? "–" : "\(controller.daySummary.highestIntensity)/10",
                            tint: .orange
                        )
                    }
                }
            }
            .padding(20)
            .frame(minWidth: 340, idealWidth: 360, maxWidth: 420)

            VStack(alignment: .leading, spacing: 20) {
                MacSectionIntro(
                    eyebrow: "Ausgewählter Tag",
                    title: controller.selectedDay.formatted(date: .complete, time: .omitted),
                    detail: daySubtitle(for: controller)
                )

                MacSurfaceCard(
                    title: "Episoden",
                    subtitle: "Wähle einen Eintrag für Details, Bearbeitung oder Löschen."
                ) {
                    if controller.selectedDayEpisodes.isEmpty {
                        ContentUnavailableView(
                            "Kein Eintrag an diesem Tag",
                            systemImage: "calendar",
                            description: Text("Lege eine neue Episode an oder wechsle im Kalender zu einem anderen Tag.")
                        )
                        .frame(maxWidth: .infinity, minHeight: 260)
                    } else {
                        List(selection: selectedEpisodeBinding) {
                            ForEach(controller.selectedDayEpisodes) { episode in
                                MacHistoryEpisodeRow(episode: episode)
                                    .tag(episode.id)
                                    .contextMenu {
                                        Button("Bearbeiten", systemImage: "pencil") {
                                            controller.editingEpisodeID = episode.id
                                        }

                                        Button("Löschen", systemImage: "trash", role: .destructive) {
                                            controller.pendingDeletionID = episode.id
                                        }
                                    }
                            }
                        }
                        .listStyle(.inset(alternatesRowBackgrounds: true))
                        .frame(minHeight: 360)
                    }
                }
            }
            .padding(20)
            .frame(minWidth: 420, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .sheet(item: editingEpisodeBinding) { item in
            NavigationStack {
                EpisodeEditorView(
                    appContainer: model.appContainer,
                    episodeID: item.id,
                    onSaved: {
                        model.historyController.editingEpisodeID = nil
                        model.historyController.reload()
                        model.refreshHistorySelection()
                    }
                )
            }
            .frame(minWidth: 700, minHeight: 760)
        }
        .confirmationDialog(
            "Episode löschen?",
            isPresented: Binding(
                get: { controller.pendingDeletionID != nil },
                set: { isPresented in
                    if !isPresented {
                        controller.pendingDeletionID = nil
                    }
                }
            ),
            titleVisibility: .visible,
            presenting: pendingEpisode
        ) { episode in
            Button("Bearbeiten") {
                controller.editingEpisodeID = episode.id
            }

            Button("Löschen", role: .destructive) {
                controller.deletePendingEpisode()
                model.refreshHistorySelection()
            }

            Button("Abbrechen", role: .cancel) {
                controller.pendingDeletionID = nil
            }
        } message: { episode in
            Text("\(episode.startedAt.formatted(date: .abbreviated, time: .shortened)) wird in den Papierkorb verschoben.")
        }
    }

    private var selectedEpisodeBinding: Binding<UUID?> {
        Binding(
            get: { model.selectedHistoryEpisodeID },
            set: { model.selectHistoryEpisode($0) }
        )
    }

    private var editingEpisodeBinding: Binding<MacIdentifiedEpisodeID?> {
        Binding(
            get: { model.historyController.editingEpisodeID.map(MacIdentifiedEpisodeID.init) },
            set: { model.historyController.editingEpisodeID = $0?.id }
        )
    }

    private var pendingEpisode: EpisodeRecord? {
        guard let pendingID = model.historyController.pendingDeletionID else {
            return nil
        }

        return model.historyController.selectedDayEpisodes.first(where: { $0.id == pendingID })
    }

    private func daySubtitle(for controller: HistoryController) -> String {
        if controller.daySummary.episodeCount == 0 {
            return "Noch kein Eintrag für diesen Tag."
        }

        return "\(controller.daySummary.episodeCount) Eintrag\(controller.daySummary.episodeCount == 1 ? "" : "e") mit höchster Intensität \(controller.daySummary.highestIntensity)/10."
    }
}

struct MacHistoryInspectorView: View {
    let model: MacAppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let episode = model.selectedHistoryEpisode {
                    MacSectionIntro(
                        eyebrow: "Inspector",
                        title: "Episode im Fokus",
                        detail: episode.startedAt.formatted(date: .complete, time: .shortened)
                    )

                    MacSurfaceCard {
                        HStack {
                            Button("Bearbeiten") {
                                model.historyController.editingEpisodeID = episode.id
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Löschen", role: .destructive) {
                                model.historyController.pendingDeletionID = episode.id
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    MacSurfaceCard(title: "Episode") {
                        MacInspectorFactRow(title: "Typ", value: episode.type.rawValue)
                        MacInspectorFactRow(title: "Intensität", value: "\(episode.intensity)/10")
                        MacInspectorFactRow(title: "Beginn", value: episode.startedAt.formatted(date: .abbreviated, time: .shortened))

                        if let endedAt = episode.endedAt {
                            MacInspectorFactRow(title: "Ende", value: endedAt.formatted(date: .abbreviated, time: .shortened))
                        }

                        if !episode.painLocation.isEmpty {
                            MacInspectorFactRow(title: "Lokalisation", value: episode.painLocation)
                        }

                        if !episode.painCharacter.isEmpty {
                            MacInspectorFactRow(title: "Charakter", value: episode.painCharacter)
                        }

                        if !episode.functionalImpact.isEmpty {
                            MacInspectorFactRow(title: "Einschränkung", value: episode.functionalImpact)
                        }
                    }

                    if !episode.symptoms.isEmpty {
                        MacSurfaceCard(title: "Symptome") {
                            MacTagFlow(items: episode.symptoms)
                        }
                    }

                    if !episode.triggers.isEmpty {
                        MacSurfaceCard(title: "Trigger") {
                            MacTagFlow(items: episode.triggers)
                        }
                    }

                    if !episode.medications.isEmpty {
                        MacSurfaceCard(title: "Medikamente") {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(episode.medications.sorted(by: { $0.takenAt < $1.takenAt })) { medication in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(medication.name)
                                            .font(.headline)

                                        Text(medicationSummary(for: medication))
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }

                    if let weather = episode.weather {
                        MacSurfaceCard(title: "Wetter") {
                            MacInspectorFactRow(title: "Zustand", value: weather.condition)
                            if let temperature = weather.temperature {
                                MacInspectorFactRow(
                                    title: "Temperatur",
                                    value: temperature.formatted(.number.precision(.fractionLength(1))) + " °C"
                                )
                            }
                            if let pressure = weather.pressure {
                                MacInspectorFactRow(
                                    title: "Luftdruck",
                                    value: pressure.formatted(.number.precision(.fractionLength(0))) + " hPa"
                                )
                            }
                        }
                    }

                    if !episode.notes.isEmpty {
                        MacSurfaceCard(title: "Notiz") {
                            Text(episode.notes)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else {
                    let controller = model.historyController

                    MacSectionIntro(
                        eyebrow: "Inspector",
                        title: "Tag im Überblick",
                        detail: controller.selectedDay.formatted(date: .complete, time: .omitted)
                    )

                    MacSurfaceCard(title: "Heute im Kontext") {
                        HStack(spacing: 12) {
                            MacMetricBadge(
                                title: "Episoden",
                                value: "\(controller.daySummary.episodeCount)",
                                tint: .blue
                            )
                            MacMetricBadge(
                                title: "Höchste Intensität",
                                value: controller.daySummary.episodeCount == 0 ? "–" : "\(controller.daySummary.highestIntensity)/10",
                                tint: .orange
                            )
                        }
                    }

                    MacSurfaceCard(title: "Nächster Schritt") {
                        Button("Neue Episode für diesen Tag anlegen") {
                            model.startNewEpisode()
                        }
                        .buttonStyle(.borderedProminent)

                        Text("Der Erfassen-Bereich übernimmt den aktuell ausgewählten Kalendertag als Startzeit.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(20)
        }
        .frame(minWidth: 320, idealWidth: 360, maxWidth: 420, maxHeight: .infinity, alignment: .topLeading)
    }

    private func medicationSummary(for medication: MedicationRecord) -> String {
        let dosage = medication.dosage.isEmpty ? medication.category.rawValue : "\(medication.category.rawValue) · \(medication.dosage)"
        return "\(dosage) · Anzahl \(medication.quantity) · \(medication.takenAt.formatted(date: .omitted, time: .shortened))"
    }
}

private struct MacHistoryEpisodeRow: View {
    let episode: EpisodeRecord

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(intensityColor)
                .frame(width: 10, height: 10)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(episode.startedAt.formatted(date: .omitted, time: .shortened))
                    .font(.headline)
                Text("\(episode.type.rawValue) · Intensität \(episode.intensity)/10")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !episode.medications.isEmpty || !episode.symptoms.isEmpty {
                    Text(metaLine)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 6)
    }

    private var metaLine: String {
        var parts: [String] = []

        if !episode.medications.isEmpty {
            parts.append("\(episode.medications.count) Medikament(e)")
        }

        if !episode.symptoms.isEmpty {
            parts.append(episode.symptoms.joined(separator: ", "))
        }

        return parts.joined(separator: " · ")
    }

    private var intensityColor: Color {
        switch episode.intensity {
        case 8...10:
            .red
        case 5...7:
            .orange
        default:
            .yellow
        }
    }
}

private struct MacHistoryMonthGrid: View {
    let month: Date
    let selectedDay: Date
    let episodesByDay: [Date: [EpisodeRecord]]
    let onSelectDay: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ForEach(dayCells) { cell in
                if let date = cell.date {
                    let stats = episodesByDay[Calendar.current.startOfDay(for: date)] ?? []

                    Button {
                        onSelectDay(date)
                    } label: {
                        VStack(spacing: 6) {
                            Text(date.formatted(.dateTime.day()))
                                .font(.subheadline.weight(.semibold))

                            if stats.isEmpty {
                                Spacer()
                                    .frame(height: 16)
                            } else {
                                Text("\(stats.count)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)

                                Circle()
                                    .fill(indicatorColor(for: stats.map(\.intensity).max() ?? 0))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 62)
                        .background(
                            Calendar.current.isDate(date, inSameDayAs: selectedDay)
                            ? Color.accentColor.opacity(0.18)
                            : Color.primary.opacity(0.04)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear
                        .frame(height: 62)
                }
            }
        }
    }

    private var weekdaySymbols: [String] {
        let calendar = Calendar.current
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    private var dayCells: [MacCalendarDay] {
        let calendar = Calendar.current
        let startOfMonth = calendar.startOfMonth(for: month)
        let range = calendar.range(of: .day, in: .month, for: startOfMonth) ?? 1 ..< 1
        let weekday = calendar.component(.weekday, from: startOfMonth)
        let leadingEmptyDays = (weekday - calendar.firstWeekday + 7) % 7

        var cells = Array(repeating: MacCalendarDay(date: nil), count: leadingEmptyDays)
        cells += range.compactMap { day -> MacCalendarDay? in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else {
                return nil
            }
            return MacCalendarDay(date: date)
        }

        while cells.count % 7 != 0 {
            cells.append(MacCalendarDay(date: nil))
        }

        return cells
    }

    private func indicatorColor(for intensity: Int) -> Color {
        switch intensity {
        case 8...10:
            .red
        case 5...7:
            .orange
        default:
            .yellow
        }
    }
}

struct MacInspectorFactRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct MacCalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
}

private struct MacIdentifiedEpisodeID: Identifiable {
    let id: UUID
}
#endif
