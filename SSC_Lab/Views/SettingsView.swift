//
//  SettingsView.swift
//  SSC_Lab
//
//  Settings screen: Account, About, Danger Zone.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.globalToastState) private var globalToastState

    @Query(sort: \Experiment.createdAt, order: .reverse) private var experiments: [Experiment]
    @Query(sort: \Win.createdAt, order: .reverse) private var wins: [Win]
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("userName") private var userName: String = ""
    
    @State private var showResetAlert = false
    @State private var showLabStorySheet = false
    @State private var isResetting = false
    
    private var hasDataToReset: Bool {
        !experiments.isEmpty || !wins.isEmpty
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
        .padding(.top, 8)
    }

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "SETTINGS")

            Form {
                Section(header: Text("ACCOUNT")) {
                    HStack(alignment: .center, spacing: 12) {
                        Text("Username")
                            .font(.appBodySmall)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.appFont)
                        Spacer(minLength: 8)
                        HStack(spacing: 6) {
                            TextField("Your name", text: $userName)
                                .font(.appBodySmall)
                                .foregroundStyle(Color.appSecondary)
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(.plain)
                            if userName.isEmpty {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.red.opacity(0.85))
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(userName.isEmpty ? Color.red.opacity(0.08) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(userName.isEmpty ? Color.red.opacity(0.35) : Color.clear, lineWidth: 1)
                        )
                    }
                }

                Section(header: Text("ABOUT")) {
                    HStack(alignment: .center, spacing: 12) {
                        Text("Developed by Mayar Alquwayfili")
                            .font(.appBodySmall)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.appFont)
                        Spacer(minLength: 8)
                        HStack(spacing: 12) {
                            Link(destination: URL(string: "https://github.com/MayarAlquwayfili")!) {
                                Image(systemName: "link")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color.appSecondary)
                            }
                            .buttonStyle(.plain)
                            Link(destination: URL(string: "https://www.linkedin.com/in/mayar-alquwayfili-2b8214331/")!) {
                                Image(systemName: "globe")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color.appSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button {
                        showLabStorySheet = true
                    } label: {
                        HStack(alignment: .center, spacing: 12) {
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
                }

                Section(header: Text("DANGER ZONE"), footer: appFooter) {
                    Button {
                        showResetAlert = true
                    } label: {
                        Text("Reset Lab")
                            .font(.appSubHeadline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(!hasDataToReset)
                    .opacity(hasDataToReset ? 1 : 0.5)

                    Text("Permanently deletes all experiments and wins. This action cannot be undone.")
                        .font(.appMicro)
                        .foregroundStyle(Color.appSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
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
    
    // Resetting overlay
    private var resettingOverlay: some View {
        ZStack {
            Color.appBg.opacity(0.6)
                .ignoresSafeArea()
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            VStack(spacing: 16) {
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

// The Story Behind
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
                    .padding(.top, 16)
                    .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
    }
}

// Reset Lab Data
extension SettingsView {
    private func resetLabData() {
        // Delete all experiments
        for experiment in experiments {
            modelContext.delete(experiment)
        }
        
        for win in wins {
            modelContext.delete(win)
        }
        
        // Preserve userName — only clear data
        try? modelContext.save()
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
