import SwiftUI

struct HomeView: View {
    let appContainer: AppContainer
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var overview: HomeOverviewData = .init(latestEpisode: nil, episodeCount: 0)
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
        .task {
            await reloadAll()
        }
        .refreshable {
            await reloadAll()
        }
        .fullScreenCover(isPresented: $isPresentingEpisodeEditor) {
            EntryFlowCoordinatorView(appContainer: appContainer) {
                isPresentingEpisodeEditor = false
                Task { await reloadOverview() }
            }
        }
    }

    private var compactDashboard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SymiSpacing.xl) {
                DiaryWelcomeCard(overview: overview)

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
                    DiaryWelcomeCard(overview: overview)
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
        await reloadOverview()
    }

    private func reloadOverview() async {
        overview = (try? await LoadHomeOverviewUseCase(repository: appContainer.episodeRepository).execute()) ?? .init(latestEpisode: nil, episodeCount: 0)
    }

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

private struct DiaryWelcomeCard: View {
    let overview: HomeOverviewData

    var body: some View {
        VStack(alignment: .leading, spacing: SymiSpacing.xl) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: SymiSpacing.secondaryButtonVerticalPadding) {
                    Text(greeting)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppTheme.foam)

                    Text(ProductBranding.marketingClaim)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(AppTheme.symiOnAccent)

                    Text(summaryDetail)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.foam.opacity(SymiOpacity.heroSecondaryText))

                    if overview.episodeCount > 0 {
                        statsRow
                    }
                }

                Spacer(minLength: SymiSpacing.md)

                VStack(spacing: SymiSpacing.sm) {
                    Image(systemName: "book.closed.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.foam)
                }
                .frame(width: SymiSize.heroSymbolWidth, height: SymiSize.heroSymbolHeight, alignment: .top)
                .background(
                    AppTheme.symiOnAccent.opacity(SymiOpacity.faintSurface),
                    in: RoundedRectangle(cornerRadius: SymiRadius.button, style: .continuous)
                )
            }
        }
        .padding(SymiSpacing.xxxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.heroGradient)
        .overlay(alignment: .bottomLeading) {
            WaveAccent()
                .stroke(AppTheme.foam.opacity(SymiOpacity.heroPrimaryWave), lineWidth: SymiStroke.heroWavePrimary)
                .frame(height: SymiSize.heroWavePrimaryHeight)
                .offset(x: SymiSpacing.heroWavePrimaryOffsetX, y: SymiSpacing.heroWavePrimaryOffsetY)
        }
        .overlay(alignment: .bottomLeading) {
            WaveAccent()
                .stroke(AppTheme.seaGlass.opacity(SymiOpacity.heroSecondaryWave), lineWidth: SymiStroke.heroWaveSecondary)
                .frame(height: SymiSize.heroWaveSecondaryHeight)
                .offset(x: SymiSpacing.heroWaveSecondaryOffsetX, y: SymiSpacing.heroWaveSecondaryOffsetY)
        }
        .overlay(alignment: .bottomLeading) {
            WaveAccent()
                .stroke(AppTheme.coral.opacity(SymiOpacity.heroAccentWave), lineWidth: SymiStroke.heroWaveAccent)
                .frame(width: SymiSize.heroWaveAccentWidth, height: SymiSize.heroWaveAccentHeight)
                .offset(x: SymiSpacing.heroWaveAccentOffsetX, y: SymiSpacing.heroWaveAccentOffsetY)
        }
        .clipShape(RoundedRectangle(cornerRadius: SymiRadius.heroCard, style: .continuous))
        .shadow(color: AppTheme.shadowColor.opacity(SymiOpacity.elevatedShadow), radius: SymiRadius.heroCard, y: SymiSpacing.md)
        .accessibilityElement(children: .combine)
    }

    private var statsRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: SymiSpacing.md) {
            Text("Bisher dokumentiert")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.foam.opacity(SymiOpacity.strongSurface))

            Spacer(minLength: 12)

            Text("\(overview.episodeCount) Eintrag\(overview.episodeCount == 1 ? "" : "e")")
                .font(.title3.weight(.bold))
                .foregroundStyle(AppTheme.symiOnAccent)
                .shadow(
                    color: AppTheme.ink.opacity(SymiOpacity.selectedFill),
                    radius: SymiShadow.heroTextRadius,
                    y: SymiShadow.heroTextYOffset
                )
        }
    }

    private var summaryTitle: String {
        if let latestEpisode = overview.latestEpisode {
            return "Dein letzter Eintrag: \(latestEpisode.type.rawValue)"
        }

        return "Schön, dass du dein Tagebuch startest."
    }

    private var summaryDetail: String {
        if let latestEpisode = overview.latestEpisode {
            return "Letzter Eintrag: \(latestEpisode.type.rawValue), Intensität \(latestEpisode.intensity)/10 · \(latestEpisode.startedAt.formatted(date: .abbreviated, time: .shortened))"
        }

        return "In Sekunden eintragen, später Muster verstehen und den Alltag ruhiger planen."
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5 ..< 12:
            return "Guten Morgen"
        case 12 ..< 18:
            return "Guten Tag"
        default:
            return "Guten Abend"
        }
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

private struct WaveAccent: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY * 0.62),
            control1: CGPoint(x: rect.width * 0.24, y: rect.maxY),
            control2: CGPoint(x: rect.width * 0.66, y: rect.minY)
        )
        return path
    }
}

#Preview {
    Text("Preview nicht verfügbar")
}
