//
//  ExperimentDetailView.swift
//  SSC_Lab
//
//  Created by yumii on 14/02/2026.
//

import SwiftUI
import SwiftData

struct ExperimentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.globalToastState) private var globalToastState
    @Query private var experiments: [Experiment]
    @Bindable var experiment: Experiment
    @State private var labViewModel = LabViewModel()

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    private let cardSize: CGFloat = 370
    private let cardBorderWidth: CGFloat = 3
    private let cardCornerRadius: CGFloat = 16
    private let topRightIconPadding: CGFloat = 8
    private let cardInternalPadding: CGFloat = 8
    private let bottomRowBadgeSpacing: CGFloat = 8
    private let badgeDimension: CGFloat = 45
    private let badgeIconDimension: CGFloat = 24
    private let scrollBottomPadding: CGFloat = 32
    private let spacingBelowCard: CGFloat = 20
    private let spacingNotesToButtons: CGFloat = 16

    private var hasReferenceURL: Bool {
        LabViewModel.hasReferenceURL(experiment)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AppHeader(title: experiment.title, onBack: { dismiss() }) {
                Button(Constants.ExperimentDetail.buttonEdit) { showEditSheet = true }
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appFont)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    detailCard
                        .frame(maxWidth: cardSize, maxHeight: cardSize)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)

                    AppNoteEditor(text: $experiment.labNotes, placeholder: Constants.Lab.placeholderNote)
                        .padding(.top, spacingBelowCard)

                    VStack(spacing: 12) {
                        if experiment.isActive {
                            primaryButton(title: Constants.ExperimentDetail.buttonLogWin) {
                                dismiss()
                            }
                        } else {
                            primaryButton(title: Constants.ExperimentDetail.buttonLetsDoIt) {
                                labViewModel.toggleActive(experiment: experiment, allExperiments: experiments, context: modelContext) { previous in
                                    globalToastState?.showActivationToast(previous: previous, undoRevert: { p in
                                        labViewModel.toggleActive(experiment: p, allExperiments: experiments, context: modelContext, onActivated: nil)
                                    })
                                }
                            }
                        }
                        secondaryButton(title: Constants.ExperimentDetail.buttonDelete) {
                            showDeleteAlert = true
                        }
                    }
                    .padding(.top, spacingNotesToButtons)
                    .padding(.bottom, scrollBottomPadding)
                }
                .padding(.horizontal, Constants.ExperimentDetail.paddingHorizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
        .toolbar(.hidden, for: .tabBar)
        .enableSwipeToBack()
        .sheet(isPresented: $showEditSheet) {
            AddNewExperimentView(experimentToEdit: experiment)
        }
        .showPopUp(
            isPresented: $showDeleteAlert,
            title: "Delete Experiment?",
            message: "This action cannot be undone.",
            primaryButtonTitle: "Delete",
            secondaryButtonTitle: "Cancel",
            primaryStyle: .destructive,
            showCloseButton: false,
            onPrimary: {
                labViewModel.delete(experiment: experiment, context: modelContext)
                dismiss()
            },
            onSecondary: {
                showDeleteAlert = false
            }
        )
    }

    // Detail Card
    private var detailCard: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: cardCornerRadius)
                        .stroke(Color.appFont, lineWidth: cardBorderWidth)
                )

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer(minLength: 0)
                    experimentIconBadge
                        .padding(.top, topRightIconPadding)
                        .padding(.trailing, topRightIconPadding)
                }

                Spacer(minLength: 0)

                Text(experiment.title)
                    .font(.appDetailCard)
                    .foregroundStyle(Color.appPrimary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 0)

                HStack(alignment: .center, spacing: bottomRowBadgeSpacing) {
                    ForEach(Array(bottomBadgeTypes.enumerated()), id: \.offset) { _, type in
                        StatusBadge(type: type, size: .large, variant: .primary)
                    }
                    Spacer(minLength: 0)
                    if hasReferenceURL {
                        linkBadge
                    }
                }
                .padding(.horizontal, cardInternalPadding)
                .padding(.bottom, cardInternalPadding)
            }
            .padding(cardInternalPadding)
        }
    }

    private var experimentIconBadge: some View {
        ZStack {
            Circle()
                .fill(Color.appPrimary)
            Image(systemName: experiment.icon)
                .font(.system(size: badgeIconDimension, weight: .medium))
                .foregroundStyle(Color.appFont)
                .frame(width: badgeDimension, height: badgeDimension, alignment: .center)
        }
        .frame(width: badgeDimension, height: badgeDimension)
    }

    private var linkBadge: some View {
        ZStack {
            Circle()
                .fill(Color.appPrimary)
            Image(systemName: "link")
                .font(.system(size: badgeIconDimension, weight: .medium))
                .foregroundStyle(Color.appFont)
                .frame(width: badgeDimension, height: badgeDimension, alignment: .center)
        }
        .frame(width: badgeDimension, height: badgeDimension)
    }

    private var bottomBadgeTypes: [BadgeType] {
        LabViewModel.bottomBadges(for: experiment)
    }

    // Buttons
    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.appPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.appSubHeadline)
                .foregroundStyle(Color.appSecondaryDark)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.appShade02)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

}

// MARK: - Preview

#Preview("Experiment Detail – 8pt padding, 45×45 icons") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Experiment.self, configurations: config)

        let pottery = Experiment(
            title: "POTTERY",
            icon: "hands.and.sparkles.fill",
            environment: "indoor",
            tools: "required",
            timeframe: "7D",
            referenceURL: "https://example.com",
            labNotes: "I can't wait to make it!"
        )
        container.mainContext.insert(pottery)

        return NavigationStack {
            ExperimentDetailView(experiment: pottery)
                .modelContainer(container)
        }
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
