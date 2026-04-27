import SwiftUI

struct HomeView: View {
    let appContainer: AppContainer
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var displayedMonth = Calendar.current.startOfMonth(for: .now)
    @State private var calendarMonthData = HistoryMonthData(month: Calendar.current.startOfMonth(for: .now), episodesByDay: [:])
    @State private var isPresentingEpisodeEditor = false

    init(appContainer: AppContainer) {
        self.appContainer = appContainer
    }

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                compactDashboard
            } else {
                regularDashboard
            }
        }
        .navigationTitle(ProductBranding.displayName)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    isPresentingEpisodeEditor = true
                } label: {
                    Label("Eintragen", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)

            }
        }
        .task(id: displayedMonth) {
            await reloadCalendarMonth()
        }
        .refreshable {
            await reloadAll()
        }
        .fullScreenCover(isPresented: $isPresentingEpisodeEditor) {
            EntryFlowCoordinatorView(appContainer: appContainer) {
                isPresentingEpisodeEditor = false
                Task { await reloadAll() }
            }
        }
    }

    private var compactDashboard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SymiSpacing.xl) {
                HomeMonthCalendarView(
                    month: displayedMonth,
                    episodesByDay: calendarMonthData.episodesByDay,
                    onPrevious: showPreviousMonth,
                    onNext: showNextMonth
                )

                Button {
                    isPresentingEpisodeEditor = true
                } label: {
                    Text("Eintrag erstellen")
                }
                .buttonStyle(SymiPrimaryButtonStyle())

                FeelingCheckInCard()

                AdaptiveDashboardCard(title: "Vertrauen") {
                    VStack(alignment: .leading, spacing: SymiSpacing.sm) {
                        Label("Deine Daten gehören dir.", systemImage: "lock")
                            .font(.headline)
                        Text("Symi bleibt lokal nutzbar. Sync und Export passieren nur, wenn du sie aktiv nutzt.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.symiTextSecondary)
                    }
                }
            }
            .padding(.horizontal, SymiSpacing.xxl)
            .padding(.vertical, SymiSpacing.xl)
        }
        .brandScreen()
    }

    private var regularDashboard: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(minimum: SymiSize.dashboardWideColumnMinWidth), spacing: AppTheme.dashboardSpacing, alignment: .top),
                    GridItem(.flexible(minimum: SymiSize.dashboardColumnMinWidth), spacing: AppTheme.dashboardSpacing, alignment: .top)
                ],
                alignment: .leading,
                spacing: AppTheme.dashboardSpacing
            ) {
                VStack(alignment: .leading, spacing: AppTheme.dashboardSpacing) {
                    HomeMonthCalendarView(
                        month: displayedMonth,
                        episodesByDay: calendarMonthData.episodesByDay,
                        onPrevious: showPreviousMonth,
                        onNext: showNextMonth
                    )
                    FeelingCheckInCard()

                    AdaptiveDashboardCard(title: "Schnellaktionen") {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: SymiSize.dashboardActionColumnMinWidth), spacing: SymiSpacing.md)],
                            alignment: .leading,
                            spacing: SymiSpacing.md
                        ) {
                            QuickActionTile("Eintragen", systemImage: "plus") {
                                isPresentingEpisodeEditor = true
                            }

                        }
                    }
                }

                VStack(alignment: .leading, spacing: AppTheme.dashboardSpacing) {
                    AdaptiveDashboardCard(title: "Vertrauen") {
                        VStack(alignment: .leading, spacing: SymiSpacing.sm) {
                            Label("Deine Daten gehören dir.", systemImage: "lock")
                                .font(.headline)
                            Text("Website und Support: symiapp.com")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.symiTextSecondary)
                        }
                    }

                }
            }
            .padding(SymiSpacing.xxxl)
            .wideContent()
        }
        .brandScreen()
        .refreshable {
            await reloadAll()
        }
    }

    private func reloadAll() async {
        await reloadCalendarMonth()
    }

    private func reloadCalendarMonth() async {
        let month = displayedMonth
        calendarMonthData = (try? await LoadHistoryMonthUseCase(repository: appContainer.episodeRepository).execute(month: month)) ?? HistoryMonthData(month: month, episodesByDay: [:])
    }

    private func showPreviousMonth() {
        displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
    }

    private func showNextMonth() {
        displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
    }

}

private struct HomeMonthCalendarView: View {
    let month: Date
    let episodesByDay: [Date: [EpisodeRecord]]
    let onPrevious: () -> Void
    let onNext: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: SymiSpacing.xs), count: 7)
    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: SymiSpacing.lg) {
            HStack(alignment: .center, spacing: SymiSpacing.md) {
                Text(month.formatted(.dateTime.month(.wide).year()))
                    .font(.system(.largeTitle, design: .serif).weight(.regular))
                    .foregroundStyle(AppTheme.symiPetrol)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: SymiSpacing.sm)

                HStack(spacing: SymiSpacing.sm) {
                    calendarNavigationButton(systemImage: "chevron.left", label: "Vorheriger Monat", action: onPrevious)
                    calendarNavigationButton(systemImage: "chevron.right", label: "Nächster Monat", action: onNext)
                }
            }

            LazyVGrid(columns: columns, spacing: SymiSpacing.compact) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.symiPetrol.opacity(SymiOpacity.heroSecondaryText))
                        .frame(maxWidth: .infinity, minHeight: 26)
                        .accessibilityHidden(true)
                }

                ForEach(Array(dayCells.enumerated()), id: \.offset) { _, cell in
                    if let date = cell.date {
                        HomeCalendarDayCell(
                            date: date,
                            isActive: calendar.isDateInToday(date),
                            entries: episodesByDay[calendar.startOfDay(for: date)] ?? []
                        )
                    } else {
                        Color.clear
                            .frame(height: 44)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .padding(.horizontal, SymiSpacing.xl)
        .padding(.vertical, SymiSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
    }

    private func calendarNavigationButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.symiPetrol)
                .frame(width: 50, height: 50)
                .background(AppTheme.symiOnAccent, in: Circle())
                .shadow(color: AppTheme.shadowColor.opacity(SymiOpacity.hairline), radius: 7, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private var weekdaySymbols: [String] {
        ["MO", "DI", "MI", "DO", "FR", "SA", "SO"]
    }

    private var dayCells: [HomeCalendarDay] {
        let startOfMonth = calendar.startOfMonth(for: month)
        let range = calendar.range(of: .day, in: .month, for: startOfMonth) ?? 1 ..< 1
        let weekday = calendar.component(.weekday, from: startOfMonth)
        let leadingEmptyDays = (weekday + 5) % 7

        var cells = Array(repeating: HomeCalendarDay(date: nil), count: leadingEmptyDays)
        cells += range.compactMap { day -> HomeCalendarDay? in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else {
                return nil
            }
            return HomeCalendarDay(date: date)
        }

        while cells.count < 42 {
            cells.append(HomeCalendarDay(date: nil))
        }

        return cells
    }
}

private struct HomeCalendarDayCell: View {
    let date: Date
    let isActive: Bool
    let entries: [EpisodeRecord]

    var body: some View {
        VStack(spacing: SymiSpacing.xxs) {
            Text(date.formatted(.dateTime.day()))
                .font(.title3.weight(isActive ? .semibold : .regular))
                .foregroundStyle(isActive ? AppTheme.symiOnAccent : AppTheme.symiTextPrimary)
                .frame(width: 36, height: 36)
                .background(isActive ? AppTheme.symiPetrol : Color.clear, in: Circle())

            if entries.isEmpty {
                Circle()
                    .fill(Color.clear)
                    .frame(width: SymiSize.calendarDot, height: SymiSize.calendarDot)
            } else {
                HStack(spacing: SymiSpacing.micro) {
                    ForEach(Array(entries.prefix(3).enumerated()), id: \.element.id) { _, entry in
                        Circle()
                            .fill(dotColor(for: entry))
                            .frame(width: SymiSize.calendarDot, height: SymiSize.calendarDot)
                    }
                }
                .frame(height: SymiSize.calendarDot)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 52)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(isActive ? "Ausgewählt" : "")
    }

    private func dotColor(for entry: EpisodeRecord) -> Color {
        switch entry.intensity {
        case 8...10:
            AppTheme.symiCoral
        case 5...7:
            AppTheme.symiSage
        default:
            AppTheme.symiPetrol.opacity(SymiOpacity.heroSecondaryText)
        }
    }

    private var accessibilityLabel: String {
        let dateText = date.formatted(date: .complete, time: .omitted)
        let selectionText = isActive ? "heute, ausgewählt" : "nicht ausgewählt"

        guard entries.isEmpty == false else {
            return "\(dateText), \(selectionText), keine Einträge"
        }

        let entryText = "\(entries.count) Eintrag\(entries.count == 1 ? "" : "e")"
        let highestIntensity = entries.map(\.intensity).max() ?? 0
        return "\(dateText), \(selectionText), \(entryText), höchste Intensität \(highestIntensity) von 10"
    }
}

private struct HomeCalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
}

struct AdaptiveDashboardCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SymiSpacing.secondaryButtonVerticalPadding) {
            Text(title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: SymiSpacing.md) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(SymiSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .brandCard()
    }
}

private struct QuickActionTile: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    init(_ title: String, systemImage: String, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: SymiSize.primaryButtonHeight, alignment: .leading)
                .padding(.horizontal, SymiSpacing.secondaryButtonVerticalPadding)
                .background(AppTheme.secondaryFill, in: RoundedRectangle(cornerRadius: SymiRadius.chip, style: .continuous))
                .foregroundStyle(AppTheme.symiPetrol)
        }
        .buttonStyle(.plain)
        .hoverEffect(.highlight)
    }
}

private struct FeelingCheckInCard: View {
    @State private var currentState = 4.0

    var body: some View {
        AdaptiveDashboardCard(title: "Wie geht es dir heute?") {
            VStack(alignment: .leading, spacing: SymiSpacing.secondaryButtonVerticalPadding) {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(Int(currentState))")
                        .font(SymiTypography.homeMetric)
                        .foregroundStyle(AppTheme.symiPetrol)
                    Text(feelingLabel)
                        .font(.headline)
                        .foregroundStyle(AppTheme.symiTextSecondary)
                }

                Slider(value: $currentState, in: 0 ... 10, step: 1)
                    .tint(AppTheme.symiCoral)
                    .accessibilityLabel("Aktueller Zustand")
                    .accessibilityValue("\(Int(currentState)) von 10")

                Text("Eine schnelle Einschätzung reicht. Details kannst du im Eintrag ergänzen.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.symiTextSecondary)
            }
        }
    }

    private var feelingLabel: String {
        switch Int(currentState) {
        case 0 ... 2:
            return "ruhig"
        case 3 ... 5:
            return "mittel"
        case 6 ... 8:
            return "spürbar"
        default:
            return "stark"
        }
    }
}

#Preview {
    Text("Preview nicht verfügbar")
}
