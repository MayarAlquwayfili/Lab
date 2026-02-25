//
//  OnboardingNameView.swift
//  SSC_Lab
//
//  Onboarding view for user's name.
//

import SwiftUI

struct OnboardingNameView: View {
    @Binding var userName: String
    @Binding var hasOnboarded: Bool
    @Environment(\.dismiss) private var dismiss

    @State private var nameInput: String = ""

    private let horizontalMargin: CGFloat = 16

    private var isNameEmpty: Bool {
        nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {

                    VStack(spacing: AppSpacing.tight) {
                        Text("Welcome to SSC Lab! 🧪")
                            .font(.appHeroSmall)
                            .foregroundStyle(Color.appFont)
                            .multilineTextAlignment(.center)

                        Text("What should we call you, Director?")
                            .font(.appBody)
                            .foregroundStyle(Color.appSecondary)
                            .multilineTextAlignment(.center)
                    }

                    TextField("Enter your name", text: $nameInput)
                        .font(.appTitle)
                        .foregroundStyle(Color.appFont)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.section)
                        .padding(.vertical, AppSpacing.card)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.appSecondary.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.top, 30)
                }
                .padding(.horizontal, horizontalMargin)

                Spacer()

                AppButton(title: "Start Experimenting", style: .primary) {
                    if !isNameEmpty {
                        userName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    hasOnboarded = true
                    dismiss()
                }
                .disabled(isNameEmpty)
                .opacity(isNameEmpty ? 0.5 : 1)
                .padding(.horizontal, horizontalMargin)
                .padding(.bottom, AppSpacing.large)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    OnboardingNameView(
        userName: .constant("Scientist"),
        hasOnboarded: .constant(false)
    )
}
