import SwiftUI

struct EpisodeWeatherStatusContent: View {
    @Environment(\.openURL) private var openURL

    let state: WeatherLoadState

    var body: some View {
        switch state {
        case .idle:
            ContentUnavailableView(
                "Wetter wird vorbereitet",
                systemImage: "cloud.sun",
                description: Text("Beim Laden wird dein ungefährer Standort verwendet, um Wetterdaten für den Episodenzeitpunkt abzurufen.")
            )
        case .loading:
            HStack(spacing: 12) {
                ProgressView()
                Text("Wetter wird ermittelt …")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        case .loaded(let weather):
            VStack(alignment: .leading, spacing: 8) {
                detailRow("Zustand", weather.condition)
                if let temperature = weather.temperature {
                    detailRow("Temperatur", temperature.formatted(.number.precision(.fractionLength(1))) + " °C")
                }
                if let humidity = weather.humidity {
                    detailRow("Luftfeuchte", humidity.formatted(.number.precision(.fractionLength(0))) + " %")
                }
                if let pressure = weather.pressure {
                    detailRow("Luftdruck", pressure.formatted(.number.precision(.fractionLength(0))) + " hPa")
                }
                if let precipitation = weather.precipitation {
                    detailRow("Niederschlag", precipitation.formatted(.number.precision(.fractionLength(1))) + " mm")
                }
                if !weather.source.isEmpty {
                    detailRow("Quelle", weather.source)
                }
                Text(WeatherAttribution.sourceDescription)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        case .unavailable(let message):
            VStack(alignment: .leading, spacing: 12) {
                Label(message, systemImage: "location.slash")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if showsLocationSettingsHint(for: message) {
                    Text("Du kannst die Standortfreigabe in den Einstellungen dieser App unter \"Standort\" auf \"Beim Verwenden der App\" ändern.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    if let settingsURL = PlatformSettingsLink.appSettingsURL {
                        Button("Einstellungen öffnen") {
                            openURL(settingsURL)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    private func showsLocationSettingsHint(for message: String) -> Bool {
        message.localizedCaseInsensitiveContains("standort")
            || message.localizedCaseInsensitiveContains("freigabe")
    }
}

struct EpisodeIntensityPicker: View {
    @Binding var value: Double

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(1 ... 10, id: \.self) { level in
                let isSelected = Int(value) == level

                Button {
                    value = Double(level)
                } label: {
                    Text("\(level)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(isSelected ? Color.accentColor : Color.appGroupedBackground)
                        .foregroundStyle(isSelected ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Intensität \(level)")
                .accessibilityHint(isSelected ? "Aktuell ausgewählt." : "Setzt die Intensität auf \(level) von 10.")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

struct EpisodeMedicationDefinitionTile: View {
    let definition: MedicationDefinitionRecord
    let isSelected: Bool
    let quantity: Int
    let onToggle: () -> Void
    let onDecrease: () -> Void
    let onIncrease: () -> Void
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: onToggle) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .imageScale(.large)
                        .foregroundStyle(isSelected ? Color.accentColor : .primary)
                        .frame(width: 28, alignment: .center)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(definition.name)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)

                        if !definition.suggestedDosage.isEmpty {
                            Text(definition.suggestedDosage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)

            if isSelected {
                HStack(spacing: 10) {
                    Text("Anzahl")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button(action: onDecrease) {
                        Image(systemName: "minus.circle")
                            .imageScale(.large)
                    }
                    .buttonStyle(.plain)

                    Text("\(quantity)")
                        .font(.headline.monospacedDigit())
                        .frame(minWidth: 24)

                    Button(action: onIncrease) {
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: isSelected ? 108 : 72, alignment: .leading)
        .background(isSelected ? Color.accentColor.opacity(0.14) : Color.appGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(isSelected ? "Medikament ausgewählt. Passe die Anzahl an." : "Wählt dieses Medikament aus.")
        .contextMenu {
            if let onEdit {
                Button("Bearbeiten", systemImage: "pencil", action: onEdit)
            }

            if let onDelete {
                Button("Löschen", systemImage: "trash", role: .destructive, action: onDelete)
            }
        }
    }

    private var accessibilityLabel: String {
        if isSelected {
            return "\(definition.name), ausgewählt, Anzahl \(quantity)"
        }

        if definition.suggestedDosage.isEmpty {
            return definition.name
        }

        return "\(definition.name), \(definition.suggestedDosage)"
    }
}

struct CustomMedicationEditorView: View {
    let state: CustomMedicationEditorSheetState
    let onCancel: () -> Void
    let onSave: (CustomMedicationDefinitionDraft) -> Void

    @State private var name: String
    @State private var category: MedicationCategory
    @State private var dosage: String

    init(
        state: CustomMedicationEditorSheetState,
        onCancel: @escaping () -> Void,
        onSave: @escaping (CustomMedicationDefinitionDraft) -> Void
    ) {
        self.state = state
        self.onCancel = onCancel
        self.onSave = onSave
        _name = State(initialValue: state.initialName)
        _category = State(initialValue: state.initialCategory)
        _dosage = State(initialValue: state.initialDosage)
    }

    var body: some View {
        Form {
            Section("Medikament") {
                TextField("Name", text: $name)
                    #if os(iOS)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    #endif

                Picker("Kategorie", selection: $category) {
                    ForEach(MedicationCategory.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }

                TextField("Dosierung", text: $dosage)
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    #endif
            }
        }
        .navigationTitle(state.isEditing ? "Medikament bearbeiten" : "Eigenes Medikament")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Abbrechen", action: onCancel)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(state.isEditing ? "Speichern" : "Hinzufügen") {
                    onSave(
                        CustomMedicationDefinitionDraft(
                            id: state.id,
                            originalSelectionKey: state.originalSelectionKey,
                            name: name,
                            category: category,
                            dosage: dosage
                        )
                    )
                }
            }
        }
    }
}

struct SelectedMedicationSummaryCard: View {
    let draft: MedicationSelectionDraft
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(draft.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(role: .destructive, action: onRemove) {
                Label("Entfernen", systemImage: "xmark.circle.fill")
                    .labelStyle(.iconOnly)
            }
            .accessibilityLabel("\(draft.name) abwählen")
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var summary: String {
        if draft.dosage.isEmpty {
            return "Anzahl \(draft.quantity)"
        }

        return "\(draft.dosage) · Anzahl \(draft.quantity)"
    }
}
