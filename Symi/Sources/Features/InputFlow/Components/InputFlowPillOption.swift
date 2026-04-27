import SwiftUI

struct InputFlowPillOption: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let isSelected: Bool
    let isDisabled: Bool
    let theme: InputFlowStepTheme
    let accessibilityIdentifier: String?
    let action: () -> Void

    init(
        title: String,
        isSelected: Bool,
        isDisabled: Bool = false,
        theme: InputFlowStepTheme,
        accessibilityIdentifier: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.theme = theme
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: SymiSpacing.compact) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .accessibilityHidden(true)
                }

                Text(title)
                    .font(SymiTypography.flowPillLabel)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(SymiTypography.compactScaleFactor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(isSelected ? theme.accent(for: colorScheme) : .primary)
            .padding(.horizontal, SymiSpacing.md)
            .padding(.vertical, SymiSpacing.pillVerticalPadding)
            .frame(maxWidth: .infinity, minHeight: SymiSize.minInteractiveHeight)
            .background(backgroundColor, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(borderColor, lineWidth: SymiStroke.hairline)
            }
            .opacity(isDisabled ? SymiOpacity.disabledContent : SymiOpacity.opaque)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel(title)
        .accessibilityValue(isSelected ? "Ausgewählt" : "Nicht ausgewählt")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier(accessibilityIdentifier ?? "input-flow-pill-\(title)")
    }

    private var backgroundColor: Color {
        if isSelected {
            return theme.selectedFill(for: colorScheme)
        }

        return SymiColors.elevatedCard(for: colorScheme)
    }

    private var borderColor: Color {
        if isSelected {
            return theme.border(for: colorScheme)
        }

        return SymiColors.subtleSeparator(for: colorScheme)
    }
}
