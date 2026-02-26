//
//  HomeView.swift
//  Lab
//
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.globalToastState) private var globalToastState
    @Environment(\.hideTabBarBinding) private var hideTabBarBinding
    @Environment(\.selectedTabBinding) private var selectedTabBinding
    @Environment(\.randomizerState) private var randomizerState
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Experiment.createdAt, order: .reverse) private var experiments: [Experiment]
    @Query(sort: \Win.date, order: .reverse) private var allWins: [Win]

    @State private var viewModel = LabViewModel()
    @State private var showQuickLog = false
    @State private var quickLogExperiment: Experiment?
    @State private var showNeedMoreExperimentsPopUp = false

    private var activeExperiment: Experiment? {
        experiments.first { $0.isActive }
    }

    private var inactiveExperiments: [Experiment] {
        experiments.filter { !$0.isActive && !$0.isCompleted }
    }

    private var lastWin: Win? { allWins.first }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AppHeader(title: "HOME") {
                pillStatus
            }
            .padding(.horizontal, AppSpacing.card)

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.block) {
                    heroSection
                    actionGrid
                    Spacer(minLength: AppSpacing.block)
                }
                .padding(.horizontal, AppSpacing.block)
                .padding(.top, AppSpacing.small)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            lastWinRow
                .padding(.horizontal, AppSpacing.block)
                .padding(.bottom, AppSpacing.large)
        }
        .background(Color.appBg)
        .onAppear {
            hideTabBarBinding?.wrappedValue = false
        }
        .sheet(isPresented: $showQuickLog) {
            QuickLogView(experimentToLog: quickLogExperiment)
        }
        .showPopUp(
            isPresented: $showNeedMoreExperimentsPopUp,
            title: "You need at least 2 experiments to spin!",
            message: "",
            primaryButtonTitle: "Got it",
            secondaryButtonTitle: "",
            useGlobal: true,
            showCloseButton: false,
            onPrimary: { showNeedMoreExperimentsPopUp = false },
            onSecondary: {}
        )
    }

    /// Components

    private var pillStatus: some View {
        Text(activeExperiment != nil ? Constants.Strings.activeStatus : "STANDBY")
            .font(.appMicro)
            .fontWeight(.semibold)
            .foregroundStyle(activeExperiment != nil ? Color.appPrimary : Color.appSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(activeExperiment != nil ? Color.appPrimary.opacity(0.15) : Color.appSecondary.opacity(0.15)))
    }

    private var heroSection: some View {
        Group {
            if let active = activeExperiment {
                HStack(alignment: .center, spacing: AppSpacing.card) {
                    heroCard(experiment: active)
                    sideButtons(experiment: active)
                }
                .frame(height: 140)
            } else {
                emptyHeroCard
            }
        }
    }

    private func heroCard(experiment: Experiment) -> some View {
        ZStack(alignment: .topLeading) {
            Color.white

            Text(experiment.title)
                .font(.appHero)
                .foregroundStyle(Color.appPrimary)
                .lineLimit(1)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Text("CURRENT EXPERIMENT")
                .font(.appMicro)
                .foregroundStyle(Color.appSecondary)
                .padding(16)

            Circle()
                .fill(Color.appPrimary)
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: experiment.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                )
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            Text(experiment.activatedAt?.timeAgoString ?? experiment.createdAt.timeAgoString)
                .font(.appMicro)
                .foregroundStyle(Color.appSecondary)
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appSecondary, lineWidth: 1.5))
    }

    private func sideButtons(experiment: Experiment) -> some View {
        VStack(spacing: 8) {
            Button {
                quickLogExperiment = experiment
                showQuickLog = true
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.appPrimary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appSecondary, lineWidth: 1.5))
            }
            .buttonStyle(.plain)

            Button {
                viewModel.toggleActive(experiment: experiment, allExperiments: experiments, context: modelContext) { previous in
                    globalToastState?.showActivationToast(previous: previous, undoRevert: { p in
                        viewModel.toggleActive(experiment: p, allExperiments: experiments, context: modelContext, onActivated: nil)
                    })
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.appAlert)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appAlert.opacity(0.3), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
        }
        .frame(width: 60)
    }

    private var emptyHeroCard: some View {
        Button { selectedTabBinding?.wrappedValue = .lab } label: {
            VStack(spacing: 8) {
                Text("No active experiment right now.\nJump to the Lab to activate one!")
                    .font(.appSubHeadline)
                    .foregroundStyle(Color.appFont)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appSecondary, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    private var actionGrid: some View {
        HStack(spacing: AppSpacing.card) {
            Button(action: performRandomPick) {
                HStack(spacing: 12) {
                    Image(systemName: "dice.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.appPrimary)
                    Text("SPIN")
                        .font(.appHeroSmall)
                        .foregroundStyle(Color.appFont)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appSecondary, lineWidth: 1.5))
            }
            .buttonStyle(.plain)

            Button {
                quickLogExperiment = nil
                showQuickLog = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.appPrimary)
                    Text("Log a Win")
                        .font(.appHeroSmall)
                        .foregroundStyle(Color.appFont)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appSecondary, lineWidth: 1.5))
            }
            .buttonStyle(.plain)
        }
    }

    private func performRandomPick() {
        guard inactiveExperiments.count >= 2,
              let state = randomizerState,
              let pick = inactiveExperiments.randomElement() else {
            showNeedMoreExperimentsPopUp = true
            return
        }
        state.present(
            experiment: pick,
            onLetsDoIt: {
                state.dismiss()
                viewModel.toggleActive(experiment: pick, allExperiments: experiments, context: modelContext, onActivated: nil)
            },
            onSpinAgain: { performRandomPick() }
        )
    }

    private var lastWinRow: some View {
        HStack {
            if let win = lastWin {
                Text("Last Win: \(win.title) • \(win.date.timeAgoString)")
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appSecondary)
            }
        }
    }
}
