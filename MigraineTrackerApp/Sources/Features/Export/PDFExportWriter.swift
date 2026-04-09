import Foundation
import UIKit

enum PDFExportWriter {
    static func write(summary: ExportPeriodSummary) throws -> URL {
        let fileName = "MigraineTracker-\(dateStamp(summary.startDate))-\(dateStamp(summary.endDate)).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842))

        try renderer.writePDF(to: url) { context in
            let pageRect = renderer.format.bounds
            let layout = PDFLayout(pageRect: pageRect)

            var page = PDFPageContext(context: context, layout: layout)
            page.beginPage()
            page.drawTitle("Migraine Tracker Bericht")
            page.drawBodyLine("Zeitraum: \(summary.startDate.formatted(date: .abbreviated, time: .omitted)) bis \(summary.endDate.formatted(date: .abbreviated, time: .omitted))")
            page.drawBodyLine("Episoden: \(summary.episodeCount)")

            if summary.episodeCount > 0 {
                page.drawBodyLine("Durchschnittliche Intensität: \(summary.averageIntensity.formatted(.number.precision(.fractionLength(1))))/10")
            }

            if !summary.medicationNames.isEmpty {
                page.drawBodyLine("Dokumentierte Medikamente: \(summary.medicationNames.joined(separator: ", "))")
            }

            page.addSpacing(18)
            page.drawSectionTitle("Episodenübersicht")

            for record in summary.records {
                let block = exportLines(for: record)
                page.drawBlock(block)
            }
        }

        return url
    }

    private static func exportLines(for record: EpisodeExportRecord) -> [String] {
        var lines: [String] = []
        lines.append("\(record.startedAt.formatted(date: .abbreviated, time: .shortened)) · \(record.type) · Intensität \(record.intensity)/10")

        if let endedAt = record.endedAt {
            lines.append("Ende: \(endedAt.formatted(date: .abbreviated, time: .shortened))")
        }

        if !record.symptoms.isEmpty {
            lines.append("Symptome: \(record.symptoms.joined(separator: ", "))")
        }

        if !record.triggers.isEmpty {
            lines.append("Trigger: \(record.triggers.joined(separator: ", "))")
        }

        if !record.functionalImpact.isEmpty {
            lines.append("Einschränkung: \(record.functionalImpact)")
        }

        if !record.medications.isEmpty {
            let medicationText = record.medications.map { medication in
                let dosageText = medication.dosage.isEmpty ? medication.category : "\(medication.category), \(medication.dosage)"
                return "\(medication.name) (\(dosageText), Wirkung: \(medication.effectiveness))"
            }
            lines.append("Medikamente: \(medicationText.joined(separator: "; "))")
        }

        if let weather = record.weather {
            var parts: [String] = []
            if !weather.condition.isEmpty {
                parts.append(weather.condition)
            }
            if let temperature = weather.temperature {
                parts.append("\(temperature.formatted(.number.precision(.fractionLength(1)))) °C")
            }
            if let humidity = weather.humidity {
                parts.append("\(humidity.formatted(.number.precision(.fractionLength(0)))) % Luftfeuchte")
            }
            if let pressure = weather.pressure {
                parts.append("\(pressure.formatted(.number.precision(.fractionLength(0)))) hPa")
            }
            if !weather.source.isEmpty {
                parts.append("Quelle: \(weather.source)")
            }

            if !parts.isEmpty {
                lines.append("Wetter: \(parts.joined(separator: ", "))")
            }
        }

        if !record.notes.isEmpty {
            lines.append("Notiz: \(record.notes)")
        }

        return lines
    }

    private static func dateStamp(_ date: Date) -> String {
        date.formatted(.dateTime.year().month(.twoDigits).day(.twoDigits))
    }
}

private struct PDFLayout {
    let pageRect: CGRect
    let margin: CGFloat = 40
    let titleFont = UIFont.systemFont(ofSize: 22, weight: .bold)
    let sectionFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
    let bodyFont = UIFont.systemFont(ofSize: 11)
    let lineSpacing: CGFloat = 5

    var contentWidth: CGFloat { pageRect.width - (margin * 2) }
    var topY: CGFloat { margin }
    var bottomY: CGFloat { pageRect.height - margin }
}

private struct PDFPageContext {
    let context: UIGraphicsPDFRendererContext
    let layout: PDFLayout
    var cursorY: CGFloat = 0

    init(context: UIGraphicsPDFRendererContext, layout: PDFLayout) {
        self.context = context
        self.layout = layout
        self.cursorY = layout.topY
    }

    mutating func beginPage() {
        context.beginPage()
        cursorY = layout.topY
    }

    mutating func drawTitle(_ text: String) {
        draw(text: text, font: layout.titleFont)
        addSpacing(10)
    }

    mutating func drawSectionTitle(_ text: String) {
        ensureSpace(for: text, font: layout.sectionFont, extraSpacing: 8)
        draw(text: text, font: layout.sectionFont)
        addSpacing(6)
    }

    mutating func drawBodyLine(_ text: String) {
        ensureSpace(for: text, font: layout.bodyFont, extraSpacing: layout.lineSpacing)
        draw(text: text, font: layout.bodyFont)
    }

    mutating func drawBlock(_ lines: [String]) {
        let estimatedHeight = lines.reduce(0) { partial, line in
            partial + height(for: line, font: layout.bodyFont) + layout.lineSpacing
        } + 8

        if cursorY + estimatedHeight > layout.bottomY {
            beginPage()
        }

        for line in lines {
            drawBodyLine(line)
        }

        addSpacing(8)
        let separatorRect = CGRect(x: layout.margin, y: cursorY, width: layout.contentWidth, height: 1)
        UIColor.systemGray4.setFill()
        UIBezierPath(rect: separatorRect).fill()
        addSpacing(10)
    }

    mutating func addSpacing(_ value: CGFloat) {
        cursorY += value
    }

    private mutating func ensureSpace(for text: String, font: UIFont, extraSpacing: CGFloat) {
        let requiredHeight = height(for: text, font: font) + extraSpacing
        if cursorY + requiredHeight > layout.bottomY {
            beginPage()
        }
    }

    private mutating func draw(text: String, font: UIFont) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraph
        ]

        let rect = CGRect(x: layout.margin, y: cursorY, width: layout.contentWidth, height: height(for: text, font: font))
        NSString(string: text).draw(with: rect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        cursorY = rect.maxY + layout.lineSpacing
    }

    private func height(for text: String, font: UIFont) -> CGFloat {
        let rect = NSString(string: text).boundingRect(
            with: CGSize(width: layout.contentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )

        return ceil(rect.height)
    }
}
