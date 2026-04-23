import SwiftUI

struct ProductInformationView: View {
    private let privacyURL = URL(string: "https://s3.privyr.com/privacy/privacy-policy.html?d=eyJlbWFpbCI6ImZldXJpZy5mZXVlcjdhQGljbG91ZC5jb20iLCJjb21wYW55IjoiTWF0dGhpYXMgV2FsbG5lci1H6WhyaSIsImdlbl9hdCI6IjIwMjYtMDQtMDlUMTE6MjI6MjUuOTYzWiJ9")!

    enum Mode {
        case standard
        case onboarding
    }

    let mode: Mode
    var acknowledge: (() -> Void)? = nil

    var body: some View {
        List {
            if mode == .onboarding {
                Section("Bevor du startest") {
                    Text("\(ProductBranding.displayName) hilft dir, Schmerzereignisse ruhig und nachvollziehbar festzuhalten. Deine Angaben bleiben zuerst auf diesem Gerät und du entscheidest, welche Zusatzdienste du nutzt.")
                    Text("Die App ist eine Dokumentationshilfe. Sie ersetzt keine medizinische Diagnose, keine Therapieentscheidung und keinen Notfallkontakt.")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Was die App macht") {
                infoRow(
                    title: "Schmerzen dokumentieren",
                    detail: "Du kannst Beginn, Dauer, Intensität, Symptome, Trigger, Medikamente und Notizen zu deinen Einträgen festhalten.",
                    systemImage: "square.and.pencil"
                )
                infoRow(
                    title: "Kontext ergänzen",
                    detail: "Wetterdaten und optional freigegebene Apple-Health-Daten können helfen, einen Tag später besser einzuordnen.",
                    systemImage: "cloud.sun"
                )
                infoRow(
                    title: "Arztgespräche vorbereiten",
                    detail: "PDF-Berichte und Backups entstehen nur, wenn du sie bewusst erzeugst. Teilen läuft über die iOS-Teilen-Funktion.",
                    systemImage: "doc.text"
                )
            }

            Section("Deine Daten") {
                infoRow(
                    title: "Lokal zuerst",
                    detail: "Einträge, Medikamente, Notizen, Trigger, Symptome, Wetter-Snapshots und gelesener Apple-Health-Kontext werden auf diesem Gerät gespeichert.",
                    systemImage: "lock"
                )
                infoRow(
                    title: "iCloud ist freiwillig",
                    detail: "Die App bleibt ohne iCloud vollständig nutzbar. Wenn du Sync aktivierst, werden App-Daten über deinen iCloud-Account abgeglichen.",
                    systemImage: "icloud"
                )
                infoRow(
                    title: "Export nur auf deinen Befehl",
                    detail: "PDF-Berichte und Backups werden lokal erstellt und erst geteilt, wenn du das aktiv auswählst.",
                    systemImage: "square.and.arrow.up"
                )
                Link(destination: privacyURL) {
                    Label("Datenschutzerklärung öffnen", systemImage: "link")
                }
            }

            Section("Berechtigungen") {
                infoRow(
                    title: "Standort für Wetter",
                    detail: "Beim Wetterabruf fragt die App nach deinem ungefähren Standort. Die Koordinaten werden nicht als eigener Tagebuchwert gespeichert.",
                    systemImage: "location"
                )
                infoRow(
                    title: "Apple Health optional",
                    detail: "Apple Health wird nur genutzt, wenn du einzelne Datentypen freigibst. Nicht verfügbare Health-Daten werden einfach ausgelassen.",
                    systemImage: "heart.text.square"
                )
                infoRow(
                    title: "Erinnerungen bleiben lokal",
                    detail: "Terminerinnerungen werden als lokale iOS-Mitteilungen geplant. Ein Termin bleibt auch ohne Mitteilungsberechtigung gespeichert.",
                    systemImage: "bell"
                )
            }

            Section("Apple Health") {
                infoRow(
                    title: "Du behältst die Kontrolle",
                    detail: "Lesen und Schreiben sind getrennt. Du kannst einzelne Health-Datentypen jederzeit in der App oder in iOS wieder deaktivieren.",
                    systemImage: "checklist"
                )
                infoRow(
                    title: "Was geschrieben wird",
                    detail: "Version 1 schreibt nur einfache Symptomdaten wie Kopfschmerz und ausgewählte Begleitsymptome. Notizen und Medikamente werden nicht an Apple Health übergeben.",
                    systemImage: "pencil.and.list.clipboard"
                )
                infoRow(
                    title: "Nicht alles ist überall verfügbar",
                    detail: "Manche Health-Datentypen gibt es erst ab neueren iOS-Versionen. Die App bleibt trotzdem nutzbar und zeigt nur verfügbare Werte.",
                    systemImage: "info.circle"
                )
            }

            Section("Wetter") {
                infoRow(
                    title: "Quelle",
                    detail: "Wetterdaten kommen von Apple Weather. Die App speichert daraus einen Snapshot passend zum Zeitpunkt deines Eintrags.",
                    systemImage: "cloud.sun"
                )
                infoRow(
                    title: "Attribution",
                    detail: LocalizedStringKey(WeatherAttribution.modifiedSourceDescription),
                    systemImage: "text.badge.checkmark"
                )

                WeatherAttributionView(showsDescription: false)
            }

            Section("Medizinischer Hinweis") {
                infoRow(
                    title: "Dokumentationshilfe",
                    detail: "Die App hilft beim Festhalten und Wiederfinden deiner eigenen Beobachtungen.",
                    systemImage: "list.clipboard"
                )
                infoRow(
                    title: "Keine Diagnose, keine Therapieempfehlung",
                    detail: "Die App bewertet deine Beschwerden nicht medizinisch und ersetzt keine ärztliche Einschätzung oder Behandlungsempfehlung.",
                    systemImage: "stethoscope"
                )
                infoRow(
                    title: "Bei Warnzeichen Hilfe holen",
                    detail: "Bei neuen, starken oder ungewohnten Symptomen, Unsicherheit oder Notfällen solltest du medizinische Hilfe kontaktieren.",
                    systemImage: "exclamationmark.triangle"
                )
            }

            Section("Version und Plattform") {
                infoRow(
                    title: "Aktueller Umfang",
                    detail: "Version 1 umfasst Tagebuch, Medikamente, Wetter, optionale Apple-Health-Anbindung, Export, Arztkontakte und lokale Termine.",
                    systemImage: "app"
                )
                infoRow(
                    title: "iPhone und Deutsch",
                    detail: "Die App ist aktuell für iPhone, Deutsch und iOS 17.6 oder neuer ausgelegt.",
                    systemImage: "iphone"
                )
                infoRow(
                    title: "Weiterentwicklung",
                    detail: "Weitere Funktionen können später folgen. Medizinische Auswertungen, zusätzliche Plattformen und komplexere Health-Abgleiche brauchen eigene Konzepte.",
                    systemImage: "arrow.triangle.branch"
                )
            }

            Section("Open Source") {
                infoRow(
                    title: "Lizenz",
                    detail: "Das Projekt steht unter der GNU GPL v3.",
                    systemImage: "doc.plaintext"
                )
                infoRow(
                    title: "Feedback und Ideen",
                    detail: "Fehler, Ideen und Verbesserungsvorschläge können als GitHub-Issue eingemeldet werden.",
                    systemImage: "bubble.left.and.text.bubble.right"
                )
                infoRow(
                    title: "Beiträge",
                    detail: "Pull Requests sind willkommen.",
                    systemImage: "arrow.triangle.pull"
                )

                Link(destination: repositoryURL) {
                    Label("Projekt auf GitHub öffnen", systemImage: "link")
                }

                Link(destination: ProductBranding.supportURL) {
                    Label("GitHub-Issues öffnen", systemImage: "exclamationmark.bubble")
                }
            }

            if mode == .onboarding {
                Section {
                    Button("Verstanden") {
                        acknowledge?()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Datenschutz und Hinweise")
        .brandGroupedScreen()
    }

    private var repositoryURL: URL { ProductBranding.repositoryURL }

    @ViewBuilder
    private func infoRow(title: LocalizedStringKey, detail: LocalizedStringKey, systemImage: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.accent)
                .frame(width: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .brandGroupedRow()
    }
}

#Preview("Standard") {
    NavigationStack {
        ProductInformationView(mode: .standard)
    }
}

#Preview("Onboarding") {
    NavigationStack {
        ProductInformationView(mode: .onboarding)
    }
}
