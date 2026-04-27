import SwiftUI

struct InputFlowProgressView: View {
    @Environment(\.colorScheme) private var colorScheme

    let currentStep: Int
    let totalSteps: Int
    let theme: InputFlowStepTheme

    init(currentStep: Int, totalSteps: Int = InputFlowStepCatalog.steps.count, theme: InputFlowStepTheme) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.theme = theme
    }

    var body: some View {
        HStack(spacing: SymiSpacing.xl) {
            GeometryReader { proxy in
                let indicatorSize = SymiSize.progressIndicator
                let trackWidth = max(proxy.size.width - indicatorSize, 1)
                let xOffset = progressPosition(in: trackWidth)
                let activeWidth = min(xOffset + indicatorSize / 2, proxy.size.width)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(
                            Color.primary.opacity(
                                colorScheme == .dark ? SymiOpacity.progressTrackDark : SymiOpacity.progressTrackLight
                            )
                        )
                        .frame(height: SymiSpacing.xxs)
                        .offset(y: indicatorSize / 2 - SymiSpacing.micro)

                    Capsule()
                        .fill(theme.accent(for: colorScheme))
                        .frame(width: activeWidth, height: SymiSpacing.xxs)
                        .offset(y: indicatorSize / 2 - SymiSpacing.micro)

                    Text("\(clampedCurrentStep)")
                        .font(.caption.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.symiOnAccent)
                        .frame(width: indicatorSize, height: indicatorSize)
                        .background(theme.accent(for: colorScheme), in: Circle())
                        .overlay {
                            Circle()
                                .stroke(
                                    AppTheme.symiOnAccent.opacity(
                                        colorScheme == .dark
                                            ? SymiOpacity.progressIndicatorStrokeDark
                                            : SymiOpacity.progressIndicatorStrokeLight
                                    ),
                                    lineWidth: SymiStroke.hairline
                                )
                        }
                        .offset(x: xOffset)
                        .accessibilityHidden(true)
                }
            }
            .frame(height: SymiSize.progressIndicator)

            Text("von \(safeTotalSteps)")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(SymiTypography.compactScaleFactor)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Schritt \(clampedCurrentStep) von \(safeTotalSteps)")
    }

    private var safeTotalSteps: Int {
        max(totalSteps, 1)
    }

    private var clampedCurrentStep: Int {
        min(max(currentStep, 1), safeTotalSteps)
    }

    private func progressPosition(in trackWidth: CGFloat) -> CGFloat {
        guard safeTotalSteps > 1 else {
            return trackWidth
        }

        return CGFloat(clampedCurrentStep - 1) / CGFloat(safeTotalSteps - 1) * trackWidth
    }
}
