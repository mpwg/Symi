# Plattform-Parität

## Ziel

`MigraineTracker` bietet auf `iOS` und `macOS` denselben fachlichen Funktionsumfang, sofern keine technische Plattformgrenze dagegen spricht. Unterschiedliche Navigation, Fensterlogik oder Desktop-/Touch-Interaktionen sind erlaubt. Unterschiede im Feature-Set sind es nicht.

## Capability-Matrix

| Capability | iOS-Zugriff | macOS-Zugriff | Hinweise |
| --- | --- | --- | --- |
| `todayFocus` | Primärnavigation über Tab `Heute` | Kontextuell im Verlauf-Workspace | Gleiches fachliches Ziel, unterschiedliche IA |
| `episodeCapture` | Primärnavigation über Tab `Erfassen` | Primärnavigation über Route `Erfassen` | Neue Episode auf beiden Plattformen direkt erreichbar |
| `historyReview` | Primärnavigation über Tab `Verlauf` | Primärnavigation über Route `Verlauf` | Kalender, Tageskontext und Details |
| `syncManagement` | Primärnavigation über Tab `Sync & Export` | Primärnavigation über Route `Synchronisation` | Status, Konflikte und Wiederherstellung |
| `dataExport` | Primärnavigation über Tab `Sync & Export` | Primärnavigation über Route `Export` | PDF, JSON5 und Import |
| `settings` | Primärnavigation über Tab `Einstellungen` | `Settings`-Scene | macOS trennt Arbeitsbereich und App-Einstellungen bewusst |
| `privacyInformation` | Sekundär innerhalb `Einstellungen` | `Settings`-Scene und Hilfsfenster | Fachlich gleich, anders eingebettet |

## Definition gleicher Features

- Ein Feature gilt als gleich, wenn dieselbe fachliche Aufgabe auf beiden Plattformen möglich ist.
- Unterschiede im Layout, in der Navigation oder im Aufrufkontext zählen nicht als Abweichung.
- Eine Plattform darf nur dann weniger anbieten, wenn die technische Einschränkung explizit im Code und in dieser Datei dokumentiert ist.
- Die gemeinsame Quelle der Wahrheit ist `AppCapability`, nicht die Shell-Navigation.

## Zulässige Abweichungen

- Desktop-spezifische Fensterstruktur auf `macOS`
- Touch-orientierte Navigation auf `iOS`
- Plattformtypische Toolbar-, Sheet-, Settings- oder Split-View-Verwendung

## Nicht zulässige Abweichungen

- Eine neue Capability ist nur auf einer Plattform erreichbar.
- Ein Feature lebt direkt in einer plattformspezifischen View und nicht in `Core` oder `Infrastructure`.
- Eine Plattform lässt einen bestehenden fachlichen Flow stillschweigend weg.

## Review-Checkliste

- Verwendet die Änderung bestehende `Core`-/`Infrastructure`-Logik statt neuer Fachlogik in der Shell?
- Ist die betroffene Funktion in `AppCapability` modelliert?
- Ist die Capability auf `iOS` und `macOS` mit einem Zugriffsweg verdrahtet?
- Falls nicht: ist die technische Begründung im Code und in dieser Datei dokumentiert?
- Bleiben Nicht-`Platforms`-Dateien frei von `UIKit`- oder `AppKit`-Imports?
