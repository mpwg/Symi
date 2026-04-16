#if os(macOS)
import SwiftUI

struct MacEpisodeCaptureWorkspaceView: View {
    let model: MacAppModel

    var body: some View {
        let editorController = model.captureController
        @Bindable var controller = editorController

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                MacSectionIntro(
                    eyebrow: "Erfassen",
                    title: "Neue Episode als Desktop-Arbeitsbereich",
                    detail: "Breitere Eingaben, ruhige Gruppen und ein permanenter Inspector ersetzen das mobile Formular."
                )

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 320), spacing: 20, alignment: .top)],
                    alignment: .leading,
                    spacing: 20
                ) {
                    MacSurfaceCard(title: "Kernangaben", subtitle: "Typ, Intensität und Zeitpunkt") {
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

                    MacSurfaceCard(title: "Symptome und Trigger", subtitle: "Schnell anwählbare Kontextmarker") {
                        MacCaptureOptionGrid(
                            title: "Symptome",
                            options: controller.symptomOptions,
                            selection: $controller.draft.selectedSymptoms
                        )

                        Divider()

                        MacCaptureOptionGrid(
                            title: "Trigger",
                            options: controller.triggerOptions,
                            selection: $controller.draft.selectedTriggers
                        )
                    }

                    MacSurfaceCard(title: "Notiz und Details", subtitle: "Freitext und optionale Ergänzungen") {
                        TextField("Kurz notieren, was auffällt", text: $controller.draft.notes, axis: .vertical)
                            .lineLimit(4 ... 8)

                        TextField("Schmerzlokalisation", text: $controller.draft.painLocation)
                        TextField("Schmerzcharakter", text: $controller.draft.painCharacter)
                        TextField("Funktionelle Einschränkung", text: $controller.draft.functionalImpact)

                        Picker("Menstruationsstatus", selection: $controller.draft.menstruationStatus) {
                            ForEach(MenstruationStatus.allCases, id: \.self) { status in
                                Text(verbatim: status.rawValue).tag(status)
                            }
                        }
                    }

                    MacSurfaceCard(title: "Wetter", subtitle: "Wird automatisch ergänzt, wenn Standortzugriff vorliegt") {
                        EpisodeWeatherStatusContent(state: controller.weatherLoadState)
                    }
                }

                MacSurfaceCard(title: "Medikamente", subtitle: "Vorlagen, eigene Einträge und Mengen im Blick") {
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
                        VStack(alignment: .leading, spacing: 18) {
                            ForEach(controller.filteredMedicationGroups) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(group.title)
                                        .font(.headline)

                                    LazyVGrid(
                                        columns: [GridItem(.adaptive(minimum: 240), spacing: 12, alignment: .top)],
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

                                    if let footer = group.footer {
                                        Text(footer)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }

                    if controller.selectedMedications.isEmpty {
                        Text("Nur ergänzen, wenn du heute etwas genommen hast.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 240), spacing: 12, alignment: .top)],
                            alignment: .leading,
                            spacing: 12
                        ) {
                            ForEach(controller.selectedMedications) { medication in
                                SelectedMedicationSummaryCard(draft: medication) {
                                    controller.removeMedicationSelection(id: medication.id)
                                }
                            }
                        }
                    }

                    HStack {
                        Button("Eigenes Medikament hinzufügen") {
                            controller.presentEditor(for: nil)
                        }

                        Spacer()

                        Button("Episode speichern") {
                            controller.save(onSaved: nil) {}
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(controller.isSaving)
                    }
                }
            }
            .padding(20)
        }
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
            .frame(minWidth: 420, minHeight: 320)
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
}

struct MacEpisodeCaptureInspectorView: View {
    let controller: EpisodeEditorController
    let resetCapture: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                MacSectionIntro(
                    eyebrow: "Inspector",
                    title: "Eintrag vor dem Speichern",
                    detail: "Zusammenfassung, Wetterstatus und aktuelle Auswahl ohne Scroll-Jagd."
                )

                MacSurfaceCard(title: "Zusammenfassung") {
                    MacInspectorFactRow(title: "Typ", value: controller.draft.type.rawValue)
                    MacInspectorFactRow(title: "Intensität", value: "\(controller.draft.intensity)/10")
                    MacInspectorFactRow(
                        title: "Beginn",
                        value: controller.draft.startedAt.formatted(date: .abbreviated, time: .shortened)
                    )

                    if controller.draft.endedAtEnabled {
                        MacInspectorFactRow(
                            title: "Ende",
                            value: controller.draft.endedAt.formatted(date: .abbreviated, time: .shortened)
                        )
                    }
                }

                MacSurfaceCard(title: "Status") {
                    HStack(spacing: 12) {
                        MacMetricBadge(
                            title: "Symptome",
                            value: "\(controller.draft.selectedSymptoms.count)",
                            tint: .blue
                        )
                        MacMetricBadge(
                            title: "Trigger",
                            value: "\(controller.draft.selectedTriggers.count)",
                            tint: .orange
                        )
                        MacMetricBadge(
                            title: "Medikamente",
                            value: "\(controller.selectedMedications.count)",
                            tint: .green
                        )
                    }

                    if let validationMessage = controller.validationMessage {
                        Label(validationMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }

                if !controller.selectedMedications.isEmpty {
                    MacSurfaceCard(title: "Gewählte Medikamente") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(controller.selectedMedications) { medication in
                                Text("\(medication.name) · Anzahl \(medication.quantity)")
                                    .font(.subheadline)
                            }
                        }
                    }
                }

                MacSurfaceCard(title: "Wetter") {
                    EpisodeWeatherStatusContent(state: controller.weatherLoadState)
                }

                MacSurfaceCard {
                    Button("Formular neu aufsetzen") {
                        resetCapture()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .frame(minWidth: 320, idealWidth: 360, maxWidth: 420, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct MacCaptureOptionGrid: View {
    let title: String
    let options: [String]
    @Binding var selection: Set<String>

    private let columns = [GridItem(.adaptive(minimum: 130), spacing: 10, alignment: .leading)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))

            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                ForEach(options, id: \.self) { option in
                    let isSelected = selection.contains(option)

                    Button {
                        if isSelected {
                            selection.remove(option)
                        } else {
                            selection.insert(option)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            Text(option)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(isSelected ? Color.accentColor.opacity(0.16) : Color.primary.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
#endif
