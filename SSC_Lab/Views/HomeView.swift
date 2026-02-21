//
//  HomeView.swift
//  SSC_Lab
//
//  Home tab: shows active experiment card and Quick Log.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.globalToastState) private var globalToastState
    @Query(sort: \Experiment.createdAt, order: .reverse) private var experiments: [Experiment]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = LabViewModel()
    @State private var showQuickLog = false

    private var activeExperiment: Experiment? {
        experiments.first { $0.isActive }
    }

    private let horizontalMargin: CGFloat = 16
    private let cardCornerRadius: CGFloat = 16
    private let cardPadding: CGFloat = 16
    private let buttonHeight: CGFloat = 44
    private let buttonSpacing: CGFloat = 12

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let active = activeExperiment {
                    // Currently Testing section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(Constants.Home.currentlyTestingTitle)
                            .font(.appSubHeadline)
                            .foregroundStyle(Color.appFont)
                            .padding(.horizontal, horizontalMargin)
                            .padding(.top, 24)

                        activeExperimentCard(experiment: active)
                            .padding(.horizontal, horizontalMargin)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    // Empty state
                    EmptyStateView(
                        title: Constants.Home.emptyStateTitle,
                        subtitle: Constants.Home.emptyStateSubtitle
                    )
                    .padding(.top, 60)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: activeExperiment?.id)
        .sheet(isPresented: $showQuickLog) {
            QuickLogView()
        }
    }

    // Active Experiment Card
    private func activeExperimentCard(experiment: Experiment) -> some View {
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

            // Buttons
            HStack(spacing: buttonSpacing) {
                Button {
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
