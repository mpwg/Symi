import SwiftUI

enum InputFlowSelectionState: Equatable, Sendable {
    case unselected
    case selected
    case disabled

    var isSelected: Bool {
        self == .selected
    }

    var isDisabled: Bool {
        self == .disabled
    }
}

struct InputFlowSelectionTile: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let systemImage: String
    let state: InputFlowSelectionState
    let theme: InputFlowStepTheme
    let accessibilityIdentifier: String?
    let action: () -> Void

    init(
        title: String,
        systemImage: String,
        isSelected: Bool,
        isDisabled: Bool = false,
        theme: InputFlowStepTheme,
        accessibilityIdentifier: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.state = isDisabled ? .disabled : (isSelected ? .selected : .unselected)
        self.theme = theme
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: SymiSpacing.sm) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: systemImage)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(iconColor)
                        .frame(width: SymiSize.inputSelectionIconWidth, height: SymiSize.inputSelectionIconHeight)

                    if state.isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(theme.accent(for: colorScheme))
                            .background(AppTheme.symiCard, in: Circle())
                            .offset(x: SymiSpacing.selectedCheckOffsetX, y: SymiSpacing.selectedCheckOffsetY)
                            .accessibilityHidden(true)
                    }
                }

                Text(title)
                    .font(SymiTypography.flowTileLabel)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(state.isDisabled ? .secondary : .primary)
                    .lineLimit(2)
                    .minimumScaleFactor(SymiTypography.compactScaleFactor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, SymiSpacing.sm)
            .padding(.vertical, SymiSpacing.flowHeaderControlSpacing + SymiSpacing.xxs)
            .frame(maxWidth: .infinity, minHeight: SymiSize.inputSelectionTileMinHeight)
            .background(tileBackground, in: RoundedRectangle(cornerRadius: SymiRadius.flowTile, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: SymiRadius.flowTile, style: .continuous)
                    .stroke(borderColor, lineWidth: state.isSelected ? SymiStroke.selectedHairline : SymiStroke.hairline)
            }
            .opacity(state.isDisabled ? SymiOpacity.disabledTile : SymiOpacity.opaque)
        }
        .buttonStyle(.plain)
        .disabled(state.isDisabled)
        .accessibilityLabel(title)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(state.isSelected ? .isSelected : [])
        .accessibilityIdentifier(accessibilityIdentifier ?? "input-flow-tile-\(title)")
    }

    private var iconColor: Color {
        if state.isDisabled {
            return .secondary
        }

        return state.isSelected ? theme.accent(for: colorScheme) : .secondary
    }

    private var tileBackground: Color {
        if state.isSelected {
            return theme.selectedFill(for: colorScheme)
        }

        return SymiColors.elevatedCard(for: colorScheme)
    }

    private var borderColor: Color {
        if state.isSelected {
            return theme.border(for: colorScheme)
        }

        return SymiColors.subtleSeparator(for: colorScheme)
    }

    private var accessibilityValue: String {
        switch state {
        case .selected:
            "Ausgewählt"
        case .unselected:
            "Nicht ausgewählt"
        case .disabled:
            "Nicht verfügbar"
        }
    }

    private var accessibilityHint: String {
        state.isSelected ? "Entfernt die Auswahl." : "Wählt diese Option aus."
    }
}
