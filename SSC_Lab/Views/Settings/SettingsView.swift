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
                                    Text("Behind the REC")
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

/// Behind the REC
private struct LabStorySheet: View {
    @Environment(\.dismiss) private var dismiss
    private let horizontalMargin: CGFloat = 16
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Behind the REC", leftContent: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .opacity(0)
            }, rightContent: {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.appSecondary)
                }
                .buttonStyle(.plain)
            })
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    Text("\"What are your hobbies?\" Honestly, I never know how to answer this because I’m basically")
                        .font(.appBody)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.appFont)
                    + Text("\"Hobby collector\"").bold()

                    Text("Recently, I discovered a word that perfectly describes me: ")
                        .font(.appBody)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.appFont)
                    + Text("Multipotentialite").bold()
                    + Text(" (someone who's insanely curious to try a range of hobbies and skills, finding joy in the journey of learning something new). One month, I’m obsessed with 3D modeling in Blender, the next, I’m writing novels, diving into UI/UX design, game development, or trying a new matcha recipe.")
                        .font(.appBody)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.appFont)
                    
                    Text("For me, the goal is simply to enjoy the experience! I also love the satisfaction of completing a checklist. I used to create random \"Summer Checklists\" to keep track of everything I wanted to do (I would even log my daily coffee just to check it off lol). But over time, I realized I wanted a \"memory box\" for all these experiments so they wouldn’t just fade away.")
                        .font(.appBody)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.appFont)
                    
                                      
                    
                VStack(spacing: 6) {                                            HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.appTitle)

                        Text("That’s how ")
                            .font(.appTitle)
                            .fontWeight(.semibold)
                        + Text("RECLAB ")
                            .font(.appTitle)
                            .fontWeight(.heavy)
                        + Text("was born")
                            .font(.appTitle)
                            .fontWeight(.semibold)
                            
                        Image(systemName: "sparkles")
                            .font(.appTitle)
                    }
                    .foregroundStyle(Color.appPrimary)
                    
                    Text("(REC)ord + (LAB)oratory")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                                                
                                       
                    
                    Text("Think about it: scientists in movies always use those old-school tape recorders to log their daily experiments, right? I wanted to capture that exact vibe.")
                        .font(.appBody)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.appFont)
                    
                    Text("In this lab, there are no rules. Every idea you want to try is an experiment, and the moment you actually do it? That's a recorded win.")
                        .font(.appBody)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.appFont)
                    
                    Text("Don't just do it... hit REC. Document the chaos, archive your journey, and build your own collection of wins.")
                        .font(.appBody)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appFont)
                }
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, horizontalMargin)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
    }
}
/// Reset Lab Data
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
