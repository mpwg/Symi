import SwiftUI

enum SymiTypography {
    static let compactScaleFactor = 0.82
    static let buttonScaleFactor = 0.85
    static let gaugeScaleFactor = 0.75
    static let headline = Font.headline
    static let body = Font.body
    static let secondary = Font.subheadline
    static let button = Font.headline.weight(.semibold)
    static let caption = Font.caption
    static let largeMetric = Font.system(size: 58, weight: .bold, design: .rounded)
    static let homeMetric = Font.system(size: 44, weight: .bold, design: .rounded)
    static let flowTitle = Font.title.weight(.bold)
    static let flowSubtitle = Font.callout
    static let flowSectionTitle = Font.callout.weight(.medium)
    static let flowTileLabel = Font.subheadline.weight(.medium)
    static let flowPillLabel = Font.footnote.weight(.medium)
    static let flowPrimaryButton = Font.headline.weight(.semibold)
    static let flowSecondaryAction = Font.callout.weight(.medium)
    static let flowSummaryTitle = Font.headline.weight(.semibold)
    static let flowSummaryLine = Font.subheadline
}
