//
//  HomeView.swift
//  SSC_Lab
//
//  Home tab
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.globalToastState) private var globalToastState
    @Environment(\.hideTabBarBinding) private var hideTabBarBinding
    @Environment(\.selectedTabBinding) private var selectedTabBinding
    @Query(sort: \Experiment.createdAt, order: .reverse) private var experiments: [Experiment]
    @Query(sort: \Win.date, order: .reverse) private var allWins: [Win]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = LabViewModel()
    @State private var showQuickLog = false
    /// When set, Quick Log sheet pre-fills from this experiment (e.g. "Log a Win" on active card). Nil = spontaneous Quick Log.
    @State private var quickLogExperiment: Experiment?
    @State private var showRandomPickSheet = false
    @State private var randomPickedExperiment: Experiment?
    @State private var showLabEmptyAlert = false

    private var activeExperiment: Experiment? {
        experiments.first { $0.isActive }
    }

    /// Experiments in the Lab that are not active (candidates for Random Pick).
    private var inactiveExperiments: [Experiment] {
        experiments.filter { !$0.isActive && !$0.isCompleted }
    }

    private var totalWinsCount: Int { allWins.count }
    private var inactiveCount: Int { inactiveExperiments.count }

    private let horizontalMargin: CGFloat = 16
    private let cardCornerRadius: CGFloat = 16
    private let cardPadding: CGFloat = 16
    private let buttonHeight: CGFloat = 44
    private let buttonSpacing: CGFloat = 12
    private let sectionSpacing: CGFloat = 24
    private let gridSpacing: CGFloat = 12

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: sectionSpacing) {
                // Section 1: Active Hero (top banner)
                section1ActiveHero
                    .padding(.horizontal, horizontalMargin)
                    .padding(.top, 24)

                // Section 2: Action Grid (2 columns)
                section2ActionGrid
                    .padding(.horizontal, horizontalMargin)

                // Section 3: Progress Summary (bottom strip)
                section3ProgressSummary
                    .padding(.horizontal, horizontalMargin)
                    .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
        .onAppear { hideTabBarBinding?.wrappedValue = false }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: activeExperiment?.id)
        .sheet(isPresented: $showQuickLog) {
            QuickLogView(experimentToLog: quickLogExperiment)
        }
        .onChange(of: showQuickLog) { _, isShowing in
            if !isShowing { quickLogExperiment = nil }
        }
        .sheet(isPresented: $showRandomPickSheet) {
            if let exp = randomPickedExperiment {
                randomPickSheet(experiment: exp)
            }
        }
        .alert("Lab is empty", isPresented: $showLabEmptyAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Lab is empty, add ideas first!")
        }
    }

    // MARK: - Section 1: Active Hero

    private var section1ActiveHero: some View {
        Group {
            if let active = activeExperiment {
                activeExperimentCard(experiment: active, winCount: winCount(for: active))
            } else {
                emptyStateHeroCard
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var emptyStateHeroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ready for a new experiment? Jump to the Lab!")
                .font(.appSubHeadline)
                .foregroundStyle(Color.appFont)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                selectedTabBinding?.wrappedValue = .lab
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "viewfinder.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Go to Lab")
                        .font(.appSubHeadline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(Color.appPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(Color.appSecondary, lineWidth: 1.5)
        )
    }

    // MARK: - Section 2: Action Grid

    private var section2ActionGrid: some View {
        HStack(spacing: gridSpacing) {
            // Left: Quick Log
            actionGridCard(
                icon: "bolt.fill",
                title: "Quick Log",
                action: {
                    quickLogExperiment = nil
                    showQuickLog = true
                }
            )

            // Right: Random Pick
            actionGridCard(
                icon: "shuffle",
                title: "Random Pick",
                action: performRandomPick
            )
        }
    }

    private func actionGridCard(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(Color.appPrimary)
                Text(title)
                    .font(.appSubHeadline)
                    .foregroundStyle(Color.appFont)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 120)
            .padding(cardPadding)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cardCornerRadius)
                    .stroke(Color.appSecondary, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func performRandomPick() {
        if inactiveExperiments.isEmpty {
            showLabEmptyAlert = true
            return
        }
        randomPickedExperiment = viewModel.randomize(from: inactiveExperiments)
        showRandomPickSheet = true
    }

    private func randomPickSheet(experiment: Experiment) -> some View {
        VStack(spacing: 20) {
            Text("Random Pick")
                .font(.appHeroSmall)
                .foregroundStyle(Color.appFont)
                .padding(.top, 24)

            VStack(alignment: .leading, spacing: 8) {
                Text(experiment.title)
                    .font(.appCard)
                    .foregroundStyle(Color.appPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                HStack(spacing: 4) {
                    Image(systemName: experiment.icon)
                        .font(.system(size: 14))
                    Text(experiment.timeframe)
                        .font(.appMicro)
                }
                .foregroundStyle(Color.appSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(cardPadding)
            .background(Color.appShade02)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, horizontalMargin)

            HStack(spacing: 12) {
                Button {
                    viewModel.toggleActive(experiment: experiment, allExperiments: experiments, context: modelContext) { previous in
                        globalToastState?.showActivationToast(previous: previous, undoRevert: { p in
                            viewModel.toggleActive(experiment: p, allExperiments: experiments, context: modelContext, onActivated: nil)
                        })
                    }
                    showRandomPickSheet = false
                    randomPickedExperiment = nil
                } label: {
                    Text("Start Now")
                        .font(.appSubHeadline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: buttonHeight)
                        .background(Color.appPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button {
                    let others = inactiveExperiments.filter { $0.id != experiment.id }
                    randomPickedExperiment = viewModel.randomize(from: others)
                    if randomPickedExperiment == nil {
                        showRandomPickSheet = false
                    }
                } label: {
                    Text("Try Another")
                        .font(.appSubHeadline)
                        .foregroundStyle(Color.appSecondaryDark)
                        .frame(maxWidth: .infinity)
                        .frame(height: buttonHeight)
                        .background(Color.appShade02)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, horizontalMargin)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
        .background(Color.appBg)
    }

    // MARK: - Section 3: Progress Summary

    private var section3ProgressSummary: some View {
        HStack(spacing: 0) {
            progressStat(label: "Total Wins", value: totalWinsCount)
            Rectangle()
                .fill(Color.appSecondary.opacity(0.3))
                .frame(width: 1)
                .padding(.vertical, 8)
            progressStat(label: "Ideas Waiting", value: inactiveCount)
        }
        .padding(cardPadding)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(Color.appSecondary, lineWidth: 1.5)
        )
    }

    private func progressStat(label: String, value: Int) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.appTimeframeL_High)
                .foregroundStyle(Color.appPrimary)
            Text(label)
                .font(.appMicro)
                .foregroundStyle(Color.appSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func winCount(for experiment: Experiment) -> Int {
        if let id = experiment.activityID {
            return allWins.filter { $0.activityID == id }.count
        }
        return allWins.filter { $0.title == experiment.title }.count
    }

    private func activeExperimentCard(experiment: Experiment, winCount: Int = 0) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(experiment.title)
                            .font(.appCard)
                            .foregroundStyle(Color.appPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)

                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.appPrimary)
                                .frame(width: 8, height: 8)
                            Text(Constants.Strings.activeStatus)
                                .font(.appMicro)
                                .foregroundStyle(Color.appPrimary)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(cardPadding)

                Divider()
                    .background(Color.appSecondary.opacity(0.3))

                HStack(spacing: buttonSpacing) {
                    Button {
                        quickLogExperiment = experiment
                        showQuickLog = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text(Constants.Home.buttonLogWin)
                                .font(.appSubHeadline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: buttonHeight)
                        .background(Color.appPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    Button {
                        viewModel.toggleActive(experiment: experiment, allExperiments: experiments, context: modelContext) { previous in
                            globalToastState?.showActivationToast(previous: previous, undoRevert: { p in
                                viewModel.toggleActive(experiment: p, allExperiments: experiments, context: modelContext, onActivated: nil)
                            })
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text(Constants.Home.buttonStop)
                                .font(.appSubHeadline)
                        }
                        .foregroundStyle(Color.appSecondaryDark)
                        .frame(maxWidth: .infinity)
                        .frame(height: buttonHeight)
                        .background(Color.appShade02)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(cardPadding)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cardCornerRadius)
                    .stroke(Color.appSecondary, lineWidth: 1.5)
            )

            if winCount > 1 {
                Text("x\(winCount)")
                    .font(.appMicro)
                    .foregroundStyle(Color.appSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.appBg.opacity(0.9)))
                    .padding(8)
            }
        }
    }
}

#Preview("HomeView – with active experiment") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Experiment.self, configurations: config)

        let pottery = Experiment(
            title: "POTTERY",
            icon: "hands.and.sparkles.fill",
            environment: "indoor",
            tools: "required",
            timeframe: "7D",
            referenceURL: "",
            labNotes: "",
            isActive: true
        )
        container.mainContext.insert(pottery)

        return HomeView()
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}

#Preview("HomeView – empty state") {
    HomeView()
}
