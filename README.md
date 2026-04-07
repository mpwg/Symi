# Migraine Tracker

Migraine Tracker ist eine App-Idee für das schnelle Erfassen von Kopfschmerzen und Migräneepisoden. Der Fokus liegt auf wenigen, klaren Eingaben, damit Betroffene Symptome, Medikamente, Wetterkontext und Arzttermine ohne großen Aufwand dokumentieren können.

## Ziel

Die App soll helfen,

- Episoden konsistent zu erfassen,
- mögliche Auslöser und Muster sichtbar zu machen,
- die Wirkung von Medikamenten besser nachzuvollziehen,
- Arzttermine mit belastbaren Verlaufsdaten vorzubereiten.

## Kernfunktionen

- Erfassung von Kopfschmerz- und Migräneepisoden
- Intensitätsskala von `1` bis `10`
- Dokumentation von Medikamenten, Dosis und Wirkung
- automatisches Anhängen von Wetterdaten zum Zeitpunkt des Eintrags
- Kalender- und Verlaufsansicht
- Erinnerungen und Verwaltung von Arztterminen
- Export einer Übersicht für Ärztinnen und Ärzte

## Produktidee

Jeder Eintrag soll so schnell wie möglich erstellt werden können. Statt langer Formulare setzt die App auf einen kompakten Ablauf:

1. Intensität wählen
2. Symptome und Medikament ergänzen
3. Wetter automatisch anhängen
4. Verlauf später in Kalender und Statistiken auswerten

## MVP

Der erste Produktumfang ist bewusst klein gehalten. Details stehen im Dokument [docs/MVP-Konzept.md](docs/MVP-Konzept.md).

Enthalten sind:

- Episoden erfassen
- Medikamente dokumentieren
- Wetterdaten speichern
- Arzttermine verwalten
- Kalender und einfache Statistiken anzeigen
- Export für Arztbesuche vorbereiten

## Mögliche Datenquellen für Wetter

- `WeatherKit` von Apple für tiefe iOS-Integration
- `Open-Meteo` als freie, einfache API für ein frühes MVP

Für einen ersten Prototyp ist `Open-Meteo` meist die pragmatischere Wahl. Später kann bei Bedarf auf `WeatherKit` erweitert werden.

## Zielgruppe

- Menschen mit wiederkehrenden Kopfschmerzen
- Menschen mit diagnostizierter Migräne
- Patientinnen und Patienten, die ihren Verlauf für Arzttermine besser dokumentieren möchten

## Nächste sinnvolle Schritte

1. UX-Flow für die Erfassung definieren
2. Datenmodell konkretisieren
3. iOS-Screens für MVP entwerfen
4. lokale Datenspeicherung und Export festlegen
