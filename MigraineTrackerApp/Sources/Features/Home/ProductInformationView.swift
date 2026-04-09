import SwiftUI

struct ProductInformationView: View {
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
                    Text("Migraine Tracker speichert deine Angaben ausschließlich lokal auf diesem Gerät. Die App dient der Dokumentation für dich und für Arztgespräche.")
                    Text("Sie ersetzt keine medizinische Diagnose, keine Therapieentscheidung und keinen Notfallkontakt.")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Datenschutz") {
                infoRow(
                    title: "Lokale Gesundheitsdaten",
                    detail: "Episoden, Medikamente, Notizen, Trigger, Symptome und optionale Wetterangaben bleiben auf dem Gerät."
                )
                infoRow(
                    title: "Kein Account, kein Backend",
                    detail: "Im MVP gibt es keine Anmeldung, keine Cloud-Synchronisation und keine Server-Speicherung."
                )
                infoRow(
                    title: "PDF-Export nur auf deinen Befehl",
                    detail: "Ein Bericht wird erst lokal erzeugt, wenn du ihn exportierst und bewusst teilst."
                )
            }

            Section("Berechtigungen") {
                infoRow(
                    title: "Derzeit keine Standortfreigabe",
                    detail: "Wetterdaten werden im aktuellen Stand nur manuell eingegeben. Deshalb fragt die App keine Standortberechtigung an."
                )
                infoRow(
                    title: "Keine Health- oder Kalender-Anbindung",
                    detail: "Apple Health, Arzttermine und andere Systemdaten sind im MVP nicht integriert."
                )
            }

            Section("Medizinische Einordnung") {
                infoRow(
                    title: "Dokumentationshilfe",
                    detail: "Die App hilft dir, Migräneepisoden, Medikamente und Auslöser strukturiert festzuhalten."
                )
                infoRow(
                    title: "Keine Diagnose, keine Therapieempfehlung",
                    detail: "Inhalte in der App sind keine ärztliche Einschätzung und keine Behandlungsempfehlung."
                )
                infoRow(
                    title: "Bei akuten Beschwerden medizinisch abklären",
                    detail: "Bei Unsicherheit, starken neuen Symptomen oder Notfällen ist medizinische Hilfe erforderlich."
                )
            }

            Section("MVP-Umfang") {
                infoRow(
                    title: "Fokus der ersten Version",
                    detail: "Episode anlegen, Medikamente erfassen, Verlauf ansehen und PDF exportieren."
                )
                infoRow(
                    title: "Plattform und Sprache",
                    detail: "Das MVP ist auf iPhone und Deutsch ausgelegt."
                )
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
    }

    @ViewBuilder
    private func infoRow(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
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
