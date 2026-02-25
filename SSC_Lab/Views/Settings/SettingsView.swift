//
//  SettingsView.swift
//  SSC_Lab
//
//  Settings: Account, About, Danger Zone.
//

import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @Environment(\.globalToastState) private var globalToastState
    @Environment(\.hideTabBarBinding) private var hideTabBarBinding

    @Query(sort: \Experiment.createdAt, order: .reverse) private var experiments: [Experiment]
    @Query(sort: \Win.createdAt, order: .reverse) private var wins: [Win]
    @Query(sort: \WinCollection.name, order: .forward) private var collections: [WinCollection]
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("userName") private var userName: String = ""
    
    @State private var showResetAlert = false
    @State private var showLabStorySheet = false
    @State private var isResetting = false
    
    private var hasDataToReset: Bool {
        !experiments.isEmpty || !wins.isEmpty || !collections.isEmpty
    }

    private var appFooter: some View {
        VStack(spacing: 4) {
            Text("Privacy: Your data is stored locally.")
                .font(.appMicro)
                .foregroundStyle(Color.appSecondary)
            Text("v 1.0.0")
                .font(.appMicro)
                .foregroundStyle(Color.appSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.tight)
    }

    private let cardCornerRadius: CGFloat = 16
    private let rowMinHeight: CGFloat = 44
    private let rowPadding: CGFloat = 16
    private let horizontalMargin: CGFloat = 16

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "SETTINGS")

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    /// ACCOUNT
                    VStack(alignment: .leading, spacing: 8) {
                       Spacer()
                        Text("ACCOUNT")
                            .font(.appSubHeadline)
                            .foregroundStyle(Color.appSecondary)

                        VStack(spacing: 0) {
                            HStack(alignment: .center, spacing: AppSpacing.small) {
                                Text("Username")
                                    .font(.appBodySmall)
                                    .foregroundStyle(Color.appFont)
                                Spacer(minLength: 8)
                                HStack(spacing: 6) {
                                    TextField("Your name", text: $userName)
                                        .font(.appBodySmall)
                                        .foregroundStyle(Color.appSecondary)
                                        .multilineTextAlignment(.trailing)
                                        .textFieldStyle(.plain)
                                        .onSubmit {
                                            globalToastState?.show("Username saved")
                                        }
                                    if userName.isEmpty {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color.appAlert.opacity(0.9))
                                    }
                                }
                            }
                            .padding(.horizontal, rowPadding)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: rowMinHeight)
                        }
                        .background(userName.isEmpty ? Color.appAlert.opacity(0.08) : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: cardCornerRadius)
                                .stroke(userName.isEmpty ? Color.appAlert.opacity(0.4) : Color.appSecondary, lineWidth: 1)
                        )
                        if userName.isEmpty {
                            Text("Username cannot be empty")
                                .font(.appMicro)
                                .foregroundStyle(Color.appAlert)
                                .padding(.leading, 12)
                        }
                    }

                    /// ABOUT
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ABOUT")
                            .font(.appSubHeadline)
                            .foregroundStyle(Color.appSecondary)

                        VStack(spacing: 0) {
                            HStack(alignment: .center, spacing: AppSpacing.small) {
                                Text("Developed by Mayar Alquwayfili")
                                    .font(.appBodySmall)
                                    .fontWeight(.regular)
                                    .foregroundStyle(Color.appFont)
                                Spacer(minLength: 8)
                                HStack(spacing: AppSpacing.small) {
                                    Link(destination: URL(string: "https://github.com/MayarAlquwayfili")!) {
                                        Image(systemName: "link")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundStyle(Color.appSecondary)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("GitHub")
                                    Link(destination: URL(string: "https://www.linkedin.com/in/mayar-alquwayfili-2b8214331/")!) {
                                        Image(systemName: "globe")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundStyle(Color.appSecondary)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("LinkedIn")
                                }
                            }
                            .padding(.horizontal, rowPadding)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: rowMinHeight)
                            Divider()
                                .background(Color.appSecondary)
                                .padding(.horizontal, rowPadding)
                            Button {
                                showLabStorySheet = true
                            } label: {
                                HStack(alignment: .center, spacing: AppSpacing.small) {
                                    Text("The Lab Story")
                                        .font(.appBodySmall)
                                        .fontWeight(.regular)
                                        .foregroundStyle(Color.appFont)
                                    Spacer(minLength: 8)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Color.appSecondary)
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, rowPadding)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: rowMinHeight)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: cardCornerRadius)
                                .stroke(Color.appSecondary, lineWidth: 1)
                        )
                    }

                    /// DANGER ZONE
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DANGER ZONE")
                            .font(.appSubHeadline)
                            .foregroundStyle(Color.appSecondary)

                        VStack(spacing: AppSpacing.tight) {
                            Button {
                                showResetAlert = true
                            } label: {
                                Text("Reset Lab")
                                    .font(.appSubHeadline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.appAlert)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            .disabled(!hasDataToReset)
                            .opacity(hasDataToReset ? 1 : 0.5)
                            .accessibilityHidden(true)
                            Text("Permanently deletes all experiments and wins. This action cannot be undone.")
                                .font(.appMicro)
                                .foregroundStyle(Color.appSecondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .accessibilityHidden(true)
                        }
                        .padding(rowPadding)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: cardCornerRadius)
                                .stroke(Color.appSecondary, lineWidth: 1)
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Reset Lab. Permanently deletes all experiments and wins. This action cannot be undone.")
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHint(hasDataToReset ? "Double tap to reset lab data" : "No data to reset")
                        .accessibilityAction {
                            if hasDataToReset {
                                showResetAlert = true
                            }
                        }
                    }

                    appFooter
                }
                .padding(.horizontal, horizontalMargin)
                .padding(.bottom, AppSpacing.large)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
        .onAppear { hideTabBarBinding?.wrappedValue = false }
        .sheet(isPresented: $showLabStorySheet) {
            LabStorySheet()
        }
        .showPopUp(
            isPresented: $showResetAlert,
            title: "Reset Lab Data",
            message: "Are you sure? This will permanently delete all logs and experiments from your lab.",
            primaryButtonTitle: "Reset",
            secondaryButtonTitle: "Cancel",
            primaryStyle: .destructive,
            showCloseButton: false,
            onPrimary: {
                showResetAlert = false
                isResetting = true
                Task {
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    await MainActor.run {
                        resetLabData()
                        isResetting = false
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        globalToastState?.show("Lab Data Reset Successfully")
                    }
                }
            },
            onSecondary: {
                showResetAlert = false
            }
        )
        .overlay {
            if isResetting {
                resettingOverlay
            }
        }
    }
    
    /// Resetting overlay
    private var resettingOverlay: some View {
        ZStack {
            Color.appBg.opacity(0.6)
                .ignoresSafeArea()
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            VStack(spacing: AppSpacing.card) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(Color.appFont)
                Text("Resetting Lab Data...")
                    .font(.appBody)
                    .foregroundStyle(Color.appFont)
            }
        }
    }
}

/// The Story Behind
private struct LabStorySheet: View {
    @Environment(\.dismiss) private var dismiss
    private let horizontalMargin: CGFloat = 16
    
    private let storyText = """
         Lab is a place for running small experiments in your daily life—trying new habits, testing ideas, and logging what works.
        
        The app helps you define experiments with clear setup (environment, tools, timeframe), track wins, and reflect in lab notes. You can filter, search, and use the Random Picker when you want to let chance choose your next experiment.
        
        Everything stays on your device. No account required. Built for the Swift Student Challenge.
        """
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "The Story Behind SSC Lab", leftContent: {
                EmptyView()
            }, rightContent: {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.appSubHeadline)
                        .foregroundStyle(Color.appPrimary)
                }
                .buttonStyle(.plain)
            })
            
            ScrollView {
                Text(storyText)
                    .font(.appBody)
                    .foregroundStyle(Color.appFont)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, horizontalMargin)
                    .padding(.top, AppSpacing.card)
                    .padding(.bottom, AppSpacing.large)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
    }
}

/   /// Reset Lab Data
extension SettingsView {
    private func resetLabData() {
        // Delete all wins first (they may reference collections)
        for win in wins {
            modelContext.delete(win)
        }

        // Delete all collections so gallery returns to "No Collections Yet"
        for collection in collections {
            modelContext.delete(collection)
        }

        // Delete all experiments (full factory reset)
        for experiment in experiments {
            modelContext.delete(experiment)
        }

        try? modelContext.save()
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
