# MVP-Konzept

## Produktziel

Das MVP von Migraine Tracker soll ein verlässliches, schnelles Migräne-Tagebuch sein. Nutzerinnen und Nutzer sollen eine Episode in wenigen Sekunden erfassen und später nachvollziehen können, wie häufig Beschwerden auftreten, welche Medikamente helfen und ob Wetter oder andere Faktoren eine Rolle spielen.

## Nicht-Ziele im MVP

Diese Punkte sind zunächst bewusst ausgeschlossen:

- komplexe Diagnose- oder Therapieempfehlungen
- Community- oder Social-Features
- umfangreiche KI-Auswertung
- Anbindung an Kliniken oder Praxissysteme
- plattformübergreifende Synchronisation als Pflichtbestandteil der ersten Version

## Zielgruppe

- Menschen mit wiederkehrenden Kopfschmerzen
- Menschen mit Migräne
- Personen, die Arzttermine mit strukturierten Verlaufsdaten vorbereiten möchten

## Kernproblem

Viele Betroffene dokumentieren Symptome unregelmäßig oder gar nicht, weil vorhandene Lösungen zu komplex wirken. Gleichzeitig fehlen bei Arztterminen oft konkrete Daten zu Intensität, Dauer, Medikamenten und möglichen Auslösern.

## Wertversprechen

Migraine Tracker reduziert Dokumentation auf das Wesentliche und ergänzt automatisch Kontextdaten wie Wetter. Dadurch entsteht ohne großen Aufwand ein verwertbarer Verlauf für den Alltag und für ärztliche Gespräche.

## MVP-Funktionsumfang

### 1. Episoden erfassen

Pro Episode sollen mindestens folgende Daten erfasst werden:

- Startzeitpunkt
- optional Endzeitpunkt oder Dauer
- Intensität von `1` bis `10`
- optionale Notiz
- optionale Begleitsymptome wie Übelkeit, Lichtempfindlichkeit, Geräuschempfindlichkeit

### 2. Medikamente dokumentieren

Zu einer Episode oder unabhängig davon:

- Medikamentenname
- Einnahmezeitpunkt
- Dosis
- subjektive Wirkung, z. B. `keine`, `teilweise`, `gut`

### 3. Wetter automatisch speichern

Beim Anlegen einer Episode:

- Temperatur
- Wetterzustand
- Luftfeuchtigkeit, sofern verfügbar
- Luftdruck, sofern verfügbar

Quelle im MVP:

- bevorzugt `Open-Meteo` oder vergleichbare freie Quelle
- `WeatherKit` später als Ausbauoption

### 4. Arzttermine verwalten

- Termin mit Datum, Uhrzeit, Ort und Notiz
- Erinnerung vor dem Termin
- schnelle Ansicht relevanter letzter Episoden vor dem Termin

### 5. Verlauf und Auswertung

- Kalenderansicht mit Tagen und Episoden
- Listenansicht der letzten Einträge
- einfache Statistiken:
  - Anzahl Episoden pro Woche/Monat
  - durchschnittliche Intensität
  - häufig verwendete Medikamente

### 6. Export

- kompakter Bericht für einen definierten Zeitraum
- zunächst als PDF oder strukturierte Textansicht

## Empfohlene Screens

1. Startseite
   - heutige Übersicht
   - Button `Episode erfassen`
   - nächster Arzttermin

2. Neue Episode
   - Intensität
   - Zeitangaben
   - Symptome
   - Notiz
   - Wetter automatisch im Hintergrund

3. Medikamente
   - neue Einnahme erfassen
   - zuletzt verwendete Medikamente schnell auswählen

4. Kalender / Verlauf
   - Tages- und Monatsansicht
   - Detailansicht pro Episode

5. Arzttermine
   - Liste kommender Termine
   - Termin anlegen und bearbeiten

6. Statistiken
   - Wochen- und Monatsübersicht
   - einfache Mustererkennung auf Basis vorhandener Daten

## UX-Prinzipien

- Erfassung in unter `10` Sekunden als Leitlinie
- große, klare Eingabeelemente
- möglichst wenige Pflichtfelder
- automatische Vorbelegung von Datum, Uhrzeit und Wetter
- sensible Gesundheitsdaten standardmäßig lokal und zurückhaltend behandeln

## Vorschlag für Datenmodell

### Episode

- `id`
- `startedAt`
- `endedAt`
- `intensity`
- `notes`
- `symptoms[]`
- `weatherSnapshotId`

### MedicationEntry

- `id`
- `episodeId`
- `name`
- `dosage`
- `takenAt`
- `effectiveness`

### WeatherSnapshot

- `id`
- `recordedAt`
- `temperature`
- `condition`
- `humidity`
- `pressure`
- `source`

### DoctorAppointment

- `id`
- `title`
- `scheduledAt`
- `location`
- `notes`
- `reminderAt`

## Technische Leitplanken für Version 1

- primär iPhone-App
- lokale Speicherung zuerst, z. B. `SwiftData` oder `Core Data`
- Wetterabruf beim Eintrag, mit Fallback bei fehlender Verbindung
- Export lokal generieren
- Datenschutz und klare Einwilligung für Standortzugriff

## Erfolgskriterien für das MVP

- Nutzer können eine Episode in kurzer Zeit erfassen
- Verlauf ist in Kalender und Liste nachvollziehbar
- Medikamente sind pro Episode sichtbar
- Wetterdaten werden zuverlässig gespeichert, wenn verfügbar
- Arzttermine können angelegt und erinnert werden
- ein nutzbarer Bericht für Arzttermine kann erzeugt werden

## Nächste Umsetzungsschritte

1. User Flows und Screen-Reihenfolge finalisieren
2. Design für Erfassung und Kalender ausarbeiten
3. Datenmodell in App-Strukturen übersetzen
4. Wetterquelle auswählen
5. lokalen Prototyp für iOS aufsetzen
