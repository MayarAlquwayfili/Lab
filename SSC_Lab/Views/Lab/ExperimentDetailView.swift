//
//  ExperimentDetailView.swift
//  SSC_Lab
//
//  Created by yumii on 14/02/2026.
//

import SwiftUI
import SwiftData
import UIKit

struct ExperimentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.globalToastState) private var globalToastState
    @Environment(\.hideTabBarBinding) private var hideTabBarBinding
    @Query private var experiments: [Experiment]
    @Bindable var experiment: Experiment
    @State private var labViewModel = LabViewModel()
    @AccessibilityFocusState private var detailFocused: Bool

    @State private var showEditSheet = false
    @State private var showLogSheet = false
    @State private var showDeleteAlert = false

    private let topRightIconPadding: CGFloat = 8
    private let bottomRowBadgeSpacing: CGFloat = 8
    private let badgeDimension: CGFloat = 45
    private let badgeIconDimension: CGFloat = 24

    private var hasReferenceURL: Bool {
        LabViewModel.hasReferenceURL(experiment)
    }

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea(.all, edges: .bottom)

            VStack(alignment: .leading, spacing: 0) {
                AppHeader(title: experiment.title, onBack: { dismiss() }) {
                    Button(Constants.ExperimentDetail.buttonEdit) { showEditSheet = true }
                        .font(.appBodySmall)
                        .foregroundStyle(Color.appFont)
                        .accessibilityLabel("Edit \(experiment.title)")
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailCardFrame { detailCardContent }
                            .frame(maxWidth: .infinity)
                            .padding(.top, DetailCardLayout.spacingHeaderToCard)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(detailCardAccessibilityLabel)
                            .accessibilityFocused($detailFocused)

                        AppNoteEditor(text: $experiment.labNotes, placeholder: Constants.Lab.placeholderNote)
                            .padding(.top, DetailCardLayout.spacingCardToContent)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(experiment.labNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Note" : "Note. \(experiment.labNotes)")

                        VStack(spacing: AppSpacing.small) {
                            if experiment.isActive {
                                AppButton(title: Constants.ExperimentDetail.buttonLogWin, style: .primary) {
                                    showLogSheet = true
                                }
                                .accessibilityHint("Double tap to log a win for this experiment")
                            } else {
                                AppButton(title: Constants.ExperimentDetail.buttonLetsDoIt, style: .primary) {
                                    labViewModel.toggleActive(experiment: experiment, allExperiments: experiments, context: modelContext) { previous in
                                        globalToastState?.showActivationToast(previous: previous, undoRevert: { p in
                                            labViewModel.toggleActive(experiment: p, allExperiments: experiments, context: modelContext, onActivated: nil)
                                        })
                                    }
                                }
                                .accessibilityHint("Double tap to set as active experiment")
                            }
                            AppButton(title: Constants.ExperimentDetail.buttonDelete, style: .secondary) {
                                showDeleteAlert = true
                            }
                            .accessibilityHint("Double tap to delete this experiment")
                        }
                        .padding(.top, DetailCardLayout.spacingContentToButtons)
                        .padding(.bottom, Constants.ExperimentDetail.scrollBottomPadding)
                    }
                    .padding(.horizontal, Constants.ExperimentDetail.paddingHorizontal)
                }
                .scrollIndicators(.hidden)
                .background(Color.appBg.ignoresSafeArea(.all, edges: .bottom))
                .ignoresSafeArea(.all, edges: .bottom)
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .accessibilityHidden(showDeleteAlert)
            .toolbar(.hidden, for: .tabBar)
            .toolbarBackground(.hidden, for: .tabBar)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .enableSwipeToBack()
            .onAppear {
                var t = Transaction()
                t.disablesAnimations = true
                withTransaction(t) { hideTabBarBinding?.wrappedValue = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { detailFocused = true }
            }
            .sheet(isPresented: $showEditSheet) {
                AddNewExperimentView(experimentToEdit: experiment)
            }
            .sheet(isPresented: $showLogSheet) {
                QuickLogView(experimentToLog: experiment)
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
                    showDeleteAlert = false
                    if let undo = labViewModel.deleteExperiment(experiment: experiment, context: modelContext) {
                        UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        globalToastState?.show(
                            "Experiment Removed",
                            style: .destructive,
                            undoTitle: "Undo",
                            onUndo: undo
                        )
                        dismiss()
                    } else {
                        globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
                    }
                },
                onSecondary: {
                    showDeleteAlert = false
                }
            )
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }

    /// Detail Card  
    private var detailCardContent: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: DetailCardLayout.cardCornerRadius)
                .fill(Color.white)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer(minLength: 0)
                    experimentIconBadge
                        .padding(.top, topRightIconPadding)
                        .padding(.trailing, topRightIconPadding)
                }

                Spacer(minLength: 0)

                VStack {
                    Text(experiment.title)
                        .font(.appDetailCard)
                        .foregroundStyle(Color.appPrimary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .minimumScaleFactor(0.7)
                        .lineSpacing(-2)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(height: 50, alignment: .center)
                .frame(maxWidth: .infinity)

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
                .padding(.horizontal, DetailCardLayout.cardInternalPadding)
                .padding(.bottom, DetailCardLayout.cardInternalPadding)
            }
            .padding(DetailCardLayout.cardInternalPadding)
        }
    }

    /// VoiceOver label for the detail card: title, Experiment, tags, optional reference link.
    private var detailCardAccessibilityLabel: String {
        let tags = detailCardTagsAccessibilityLabel
        let refPart = hasReferenceURL ? " Reference link available." : ""
        return "\(experiment.title). Experiment. Tags: \(tags).\(refPart)"
    }

    /// Badge list for VoiceOver (same as ExperimentCard).
    private var detailCardTagsAccessibilityLabel: String {
        let fromBadges = bottomBadgeTypes.map { type in
            switch type {
            case .indoor: return "Indoor"
            case .outdoor: return "Outdoor"
            case .tools: return "Tools"
            case .noTools: return "No tools"
            case .oneTime: return "One time"
            case .newInterest: return "New interest"
            case .link: return "Link"
            case .timeframe(let label): return TimeframeAccessibilityLabel.spoken(for: label)
            }
        }
        return fromBadges.isEmpty ? "(none)" : fromBadges.joined(separator: ", ")
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
