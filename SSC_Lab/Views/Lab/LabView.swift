//
//  LabView.swift
//  SSC_Lab
//
//  Created by yumii on 11/02/2026.
//

import SwiftUI
import SwiftData
import UIKit

struct LabView: View {
    @Binding var hideTabBar: Bool
    @Environment(\.globalToastState) private var globalToastState
    @Environment(\.randomizerState) private var randomizerState

    @Query(filter: #Predicate<Experiment> { !$0.isCompleted }, sort: \Experiment.createdAt, order: .reverse) private var experiments: [Experiment]
    @Query(sort: \Win.date, order: .reverse) private var allWins: [Win]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = LabViewModel()
    @State private var showAddSheet = false
    @State private var selectedExperiment: Experiment?
    @State private var experimentToEdit: Experiment?
    @State private var showEditSheet = false
    @State private var showQuickLogSheet = false
    @State private var experimentForLog: Experiment?
    @State private var showNeedMoreExperimentsPopUp = false
    @State private var searchText = ""
    @State private var filterCriteria = FilterCriteria()
    @State private var showFilterSheet = false

    @AppStorage("userName") private var userName = ""
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var showOnboarding = false

    private let horizontalMargin: CGFloat = Constants.Lab.horizontalMargin
    private let gridSpacing: CGFloat = Constants.Lab.gridSpacing
    
    private var dynamicLabTitle: String {
        userName.isEmpty ? "My Lab" : "\(userName)'s Lab"
    }

    private var filteredExperiments: [Experiment] {
        viewModel.filteredExperiments(experiments, searchText: searchText, filterCriteria: filterCriteria)
    }

    init(hideTabBar: Binding<Bool> = .constant(false)) {
        _hideTabBar = hideTabBar
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
                AppHeader(title: dynamicLabTitle) {
                    HStack(spacing: 4) {
                        EmptyView().navButton(icon: "dice.fill") {
                            if filteredExperiments.count < 2 {
                                showNeedMoreExperimentsPopUp = true
                            } else {
                                pickRandomAndShowResult()
                            }
                        }
                        .accessibilityLabel("Random experiment")
                        .accessibilityHint("Double tap to randomly select an experiment from your lab")
                        EmptyView().navButton(icon: "plus") { showAddSheet = true }
                        .accessibilityLabel("Add experiment")
                        .accessibilityHint("Double tap to create a new experiment")
                    }
                }

                Spacer()
                    .frame(height: AppSpacing.small)

                // Tools: Search (leading), Filter (trailing)
                HStack(spacing: AppSpacing.small) {
                    CustomSearchBar(text: $searchText)
                        .frame(maxWidth: .infinity)

                    Button {
                        dismissKeyboard()
                        showFilterSheet = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(filterCriteria.isEmpty ? Color.appSecondary : Color.appPrimary)
                            if !filterCriteria.isEmpty {
                                Circle()
                                    .fill(Color.appPrimary)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 4, y: -4)
                            }
                        }
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(filterCriteria.isEmpty ? "Filter" : "Filter, active")
                    .accessibilityHint("Double tap to filter experiments by category")
                }
                .padding(.horizontal, horizontalMargin)

                Spacer()
                    .frame(height: AppSpacing.card)

                if experiments.isEmpty {
                    Text("No experiments yet. Tap Add experiment to start your first one.")
                        .font(.appBody)
                        .foregroundStyle(Color.appSecondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .multilineTextAlignment(.center)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("No experiments yet. Tap Add experiment to start your first one.")
                } else if filteredExperiments.isEmpty {
                    searchEmptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: gridSpacing),
                            GridItem(.flexible(), spacing: gridSpacing)
                        ], spacing: gridSpacing) {
                            ForEach(filteredExperiments) { experiment in
                                Button {
                                    selectedExperiment = experiment
                                } label: {
                                    ExperimentCard(
                                        title: experiment.title,
                                        icon: experiment.icon,
                                        hasLink: !experiment.referenceURL.isEmpty,
                                        topBadges: [LabViewModel.topBadge(for: experiment.environment)],
                                        bottomBadges: LabViewModel.bottomBadges(for: experiment),
                                        winCount: winCount(for: experiment)
                                    )
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    SharedEditMenuItem {
                                        experimentToEdit = experiment
                                        showEditSheet = true
                                    }
                                    Button {
                                        viewModel.toggleActive(experiment: experiment, allExperiments: experiments, context: modelContext) { previous in
                                            globalToastState?.showActivationToast(previous: previous, undoRevert: { p in
                                                viewModel.toggleActive(experiment: p, allExperiments: experiments, context: modelContext, onActivated: nil)
                                            })
                                        }
                                    } label: {
                                        Label("Let's do it!", systemImage: "play.circle")
                                    }
                                    Button {
                                        experimentForLog = experiment
                                        showQuickLogSheet = true
                                    } label: {
                                        Label("Log a Win", systemImage: "star.circle.fill")
                                    }
                                    Divider()
                                    SharedDeleteMenuItem {
                                        performDelete(experiment: experiment)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, horizontalMargin)
                        .padding(.top, AppSpacing.tight)
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: filteredExperiments.count)
                    }
                    .scrollDismissesKeyboard(.immediately)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg)
            .navigationBarHidden(true)
            .onAppear { hideTabBar = false }
            .onChange(of: filteredExperiments.count) { _, count in
                let msg = count == 0 ? "No results found" : "\(count) results found"
                UIAccessibility.post(notification: .announcement, argument: msg)
            }
            .navigationDestination(item: $selectedExperiment) { experiment in
                ExperimentDetailView(experiment: experiment)
                    .navigationBarBackButtonHidden(true)
                    .onAppear { hideTabBar = true }
                    .onDisappear { selectedExperiment = nil }
            }
            .sheet(isPresented: $showAddSheet) {
                AddNewExperimentView()
            }
            .sheet(isPresented: $showEditSheet) {
                if let experiment = experimentToEdit {
                    AddNewExperimentView(experimentToEdit: experiment)
                }
            }
            .sheet(isPresented: $showQuickLogSheet) {
                QuickLogView(experimentToLog: experimentForLog)
            }
            .onChange(of: showQuickLogSheet) { _, isShowing in
                if !isShowing { experimentForLog = nil }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSheetView(allExperiments: experiments, filterCriteria: $filterCriteria)
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
            .sheet(isPresented: $showOnboarding) {
                OnboardingNameView(userName: $userName, hasOnboarded: $hasOnboarded)
                    .interactiveDismissDisabled()
            }
            .onAppear {
                if !hasOnboarded {
                    showOnboarding = true
                }
            }
    }
    
    private func pickRandomAndShowResult() {
        guard filteredExperiments.count >= 2,
              let state = randomizerState,
              let pick = filteredExperiments.randomElement() else { return }
        showRandomizer(experiment: pick, state: state)
    }

    /// Presents the randomizer overlay at root (MainTabView). Recurses for "Spin Again".
    private func showRandomizer(experiment pick: Experiment, state: RandomizerState) {
        state.present(
            experiment: pick,
            onLetsDoIt: {
                state.dismiss()
                viewModel.toggleActive(experiment: pick, allExperiments: experiments, context: modelContext) { previous in
                    globalToastState?.showActivationToast(previous: previous, undoRevert: { p in
                        viewModel.toggleActive(experiment: p, allExperiments: experiments, context: modelContext, onActivated: nil)
                    })
                }
            },
            onSpinAgain: {
                let others = filteredExperiments.filter { $0.id != pick.id }
                let newPick = others.randomElement() ?? pick
                showRandomizer(experiment: newPick, state: state)
            }
        )
    }

    // Search empty state (experiments exist but filter/search have no matches)
    private var searchEmptyStateButtonTitle: String {
        let searchActive = !searchText.isEmpty
        let filterActive = !filterCriteria.isEmpty
        if searchActive && filterActive { return "Clear All" }
        if searchActive { return "Clear Search" }
        return "Clear Filters"
    }

    private var searchEmptyStateIcon: String {
        let searchActive = !searchText.isEmpty
        let filterActive = !filterCriteria.isEmpty
        if searchActive && filterActive { return "xmark.circle" }
        if searchActive { return "magnifyingglass" }
        return "line.3.horizontal.decrease.circle"
    }

    private var searchEmptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: AppSpacing.card) {
                Image(systemName: searchEmptyStateIcon)
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(Color.appSecondary)
                    .accessibilityHidden(true)
                Text("No matches found")
                    .font(.appBody)
                    .foregroundStyle(Color.appFont)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("No matches found")
                Button { clearSearchAndFilter() } label: {
                    Text(searchEmptyStateButtonTitle)
                        .font(.appSubHeadline)
                        .foregroundStyle(Color.appPrimary)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
    }

    private func clearSearchAndFilter() {
        if !searchText.isEmpty && !filterCriteria.isEmpty {
            searchText = ""
            filterCriteria = FilterCriteria()
        } else if !searchText.isEmpty {
            searchText = ""
        } else {
            filterCriteria = FilterCriteria()
        }
    }

    /// Win count for repeat badge: match by activityID when available, else by title (backwards compat).
    private func winCount(for experiment: Experiment) -> Int {
        if let id = experiment.activityID {
            return allWins.filter { $0.activityID == id }.count
        }
        return allWins.filter { $0.title == experiment.title }.count
    }

    private func performDelete(experiment: Experiment) {
        if let undo = viewModel.deleteExperiment(experiment: experiment, context: modelContext) {
            globalToastState?.show(
                "Experiment Removed",
                style: .destructive,
                undoTitle: "Undo",
                onUndo: undo
            )
        } else {
            globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
        }
    }
}


// Search Bar
private struct CustomSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(Color.appSecondary)
            
            TextField("Search experiments...", text: $text)
                .font(.appBody)
                .foregroundStyle(Color.appFont)
                .tint(Color.appPrimary)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.appSecondary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, AppSpacing.small)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appSecondary.opacity(0.3), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Search experiments")
    }
}

#Preview {
    LabView()
}
 
