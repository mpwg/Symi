import SwiftUI

struct EpisodeEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var controller: EpisodeEditorController

    private let onSaved: (() -> Void)?

    init(
        appContainer: AppContainer,
        episodeID: UUID? = nil,
        initialStartedAt: Date? = nil,
        onSaved: (() -> Void)? = nil
    ) {
        self.onSaved = onSaved
        _controller = State(
            initialValue: appContainer.makeEpisodeEditorController(
                episodeID: episodeID,
                initialStartedAt: initialStartedAt
            )
        )
    }

    var body: some View {
        @Bindable var controller = controller

        Form {
            if let validationMessage = controller.validationMessage {
                Section {
                    Label(validationMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .accessibilityLabel("Fehler: \(validationMessage)")
                }
            }

            Section {
                Picker("Typ", selection: $controller.draft.type) {
                    ForEach(EpisodeType.allCases) { episodeType in
                        Text(episodeType.rawValue).tag(episodeType)
                    }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Intensität")
                        Spacer()
                        Text("\(controller.draft.intensity)/10")
                            .font(.headline)
                            .monospacedDigit()
                    }

                    EpisodeIntensityPicker(value: Binding(
                        get: { Double(controller.draft.intensity) },
                        set: { controller.draft.intensity = Int($0) }
                    ))
                }

                DatePicker(
                    "Beginn",
                    selection: $controller.draft.startedAt,
                    in: ...Date.now,
                    displayedComponents: [.date, .hourAndMinute]
                )
            } header: {
                Text("Schneller Eintrag")
            } footer: {
                Text("Nur Typ, Intensität und Zeitpunkt sind direkt sichtbar. Alles Weitere ist optional.")
            }

            tagSection(title: "Symptome", options: controller.symptomOptions, selection: $controller.draft.selectedSymptoms)
            tagSection(title: "Trigger", options: controller.triggerOptions, selection: $controller.draft.selectedTriggers)

            Section("Notiz") {
                TextField("Kurz notieren, was auffällt", text: $controller.draft.notes, axis: .vertical)
                    .lineLimit(2 ... 5)
            }

            Section("Optionale Details") {
                DisclosureGroup("Weitere Angaben") {
                    TextField("Schmerzlokalisation", text: $controller.draft.painLocation)
                    TextField("Schmerzcharakter", text: $controller.draft.painCharacter)
                    TextField("Funktionelle Einschränkung", text: $controller.draft.functionalImpact)

                    Picker("Menstruationsstatus", selection: $controller.draft.menstruationStatus) {
                        ForEach(MenstruationStatus.allCases, id: \.self) { status in
                            Text(verbatim: status.rawValue).tag(status)
                        }
                    }

                    Toggle("Ende angeben", isOn: $controller.draft.endedAtEnabled.animation())
                    if controller.draft.endedAtEnabled {
                        DatePicker(
                            "Ende",
                            selection: $controller.draft.endedAt,
                            in: controller.draft.startedAt...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
            }

            Section {
                EpisodeWeatherStatusContent(state: controller.weatherLoadState)
            } header: {
                Text("Wetter")
            } footer: {
                Text("Das Wetter wird mit deinem ungefähren Standort über Open-Meteo auf Basis von DWD ICON geladen. Die Episode wird auch ohne Wetter gespeichert, wenn keine Freigabe vorliegt.")
            }

            Section("Medikamente") {
                TextField("Medikament nach Namen filtern", text: $controller.medicationSearchText)
                    #if os(iOS)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    #endif

                if controller.filteredMedicationGroups.isEmpty {
                    ContentUnavailableView(
                        "Kein Medikament gefunden",
                        systemImage: "magnifyingglass",
                        description: Text("Passe den Suchbegriff an oder füge ein eigenes Medikament hinzu.")
                    )
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(controller.filteredMedicationGroups) { group in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(group.title)
                                    .font(.headline)

                                LazyVGrid(
                                    columns: [GridItem(.adaptive(minimum: 220), spacing: 12, alignment: .top)],
                                    alignment: .leading,
                                    spacing: 12
                                ) {
                                    ForEach(group.items) { definition in
                                        EpisodeMedicationDefinitionTile(
                                            definition: definition,
                                            isSelected: controller.isMedicationSelected(definition),
                                            quantity: controller.quantity(for: definition),
                                            onToggle: { controller.toggleMedicationSelection(for: definition) },
                                            onDecrease: { controller.decrementMedicationQuantity(for: definition) },
                                            onIncrease: { controller.incrementMedicationQuantity(for: definition) },
                                            onEdit: definition.isCustom ? { controller.presentEditor(for: definition) } : nil,
                                            onDelete: definition.isCustom ? { controller.pendingMedicationDeletion = definition } : nil
                                        )
                                    }
                                }
                                .padding(12)
                                .background(Color.appPrimaryBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                                if let footer = group.footer {
                                    Text(footer)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                if controller.selectedMedications.isEmpty {
                    Text("Nur ergänzen, wenn du heute etwas genommen hast.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ausgewählt")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)

                        ForEach(controller.selectedMedications) { medication in
                            SelectedMedicationSummaryCard(draft: medication) {
                                controller.removeMedicationSelection(id: medication.id)
                            }
                        }
                    }
                }

                Button {
                    controller.presentEditor(for: nil)
                } label: {
                    Label("Eigenes Medikament hinzufügen", systemImage: "plus.circle")
                }
            }

            Section {
                Button(controller.mode == .create ? "Episode speichern" : "Änderungen speichern") {
                    controller.save(onSaved: onSaved) {
                        dismiss()
                    }
                }
                .disabled(controller.isSaving)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle(controller.mode == .create ? "Erfassen" : "Episode bearbeiten")
        .toolbar {
            if showsDismissButton {
                ToolbarItem(placement: dismissButtonPlacement) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
        #if os(iOS)
        .scrollDismissesKeyboard(.interactively)
        #endif
        .alert("Episode gespeichert", isPresented: $controller.saveMessageVisible) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Die Episode wurde lokal gespeichert.")
        }
        .sheet(item: $controller.customMedicationEditor) { editorState in
            NavigationStack {
                CustomMedicationEditorView(
                    state: editorState,
                    onCancel: { controller.customMedicationEditor = nil },
                    onSave: { draft in
                        controller.saveCustomMedication(from: draft)
                    }
                )
            }
            .presentationDetents([.medium])
        }
        .alert(
            "Eigenes Medikament löschen?",
            isPresented: Binding(
                get: { controller.pendingMedicationDeletion != nil },
                set: { isPresented in
                    if !isPresented {
                        controller.pendingMedicationDeletion = nil
                    }
                }
            ),
            presenting: controller.pendingMedicationDeletion
        ) { definition in
            Button("Löschen", role: .destructive) {
                controller.deleteCustomMedication(definition)
            }
            Button("Abbrechen", role: .cancel) {
                controller.pendingMedicationDeletion = nil
            }
        } message: { definition in
            Text("\(definition.name) wird aus SwiftData entfernt.")
        }
        .task(id: controller.draft.startedAt) {
            await controller.refreshWeather()
        }
    }

    @ViewBuilder
    private func tagSection(title: String, options: [String], selection: Binding<Set<String>>) -> some View {
        Section(title) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
                ForEach(options, id: \.self) { option in
                    let isSelected = selection.wrappedValue.contains(option)

                    Button {
                        if isSelected {
                            selection.wrappedValue.remove(option)
                        } else {
                            selection.wrappedValue.insert(option)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .imageScale(.medium)
                            Text(option)
                                .font(.subheadline.weight(.medium))
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .background(isSelected ? Color.accentColor.opacity(0.16) : Color.appGroupedBackground)
                        .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(title): \(option)")
                    .accessibilityHint(isSelected ? "Entfernt die Auswahl." : "Wählt diese Option aus.")
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
    }

    private var showsDismissButton: Bool {
        onSaved != nil || controller.mode == .edit
    }

    private var dismissButtonPlacement: ToolbarItemPlacement {
        #if os(macOS)
        .automatic
        #else
        .topBarLeading
        #endif
    }
}


#Preview {
    Text("Preview nicht verfügbar")
}
