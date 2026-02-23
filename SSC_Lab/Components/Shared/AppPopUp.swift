//
//  AppPopUp.swift
//  SSC_Lab
//
//  Reusable modal popup: dimmed overlay + white card with title, message, two buttons.
//

import SwiftUI

struct AppPopUp: View {
    var title: String
    var message: String
    var primaryButtonTitle: String
    var secondaryButtonTitle: String
    var primaryStyle: AppButtonStyle = .primary
    var onClose: (() -> Void)? = nil
    var onPrimary: () -> Void
    var onSecondary: () -> Void

    private let cardPadding: CGFloat = 24
    private let cornerRadius: CGFloat = 26
    private let closeButtonPadding: CGFloat = 8

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                // Reserve space for X so title sits below it
                Spacer()
                    .frame(height: onClose != nil ? 40 : 0)

                Text(title)
                    .font(.appHeroSmall)
                    .foregroundStyle(Color.appFont)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, AppSpacing.large)

                if !message.isEmpty {
                    Text(message)
                        .font(.appBodySmall)
                        .foregroundStyle(Color.appSecondaryDark)
                        .multilineTextAlignment(.center)
                        .padding(.top, AppSpacing.small)
                        .frame(maxWidth: .infinity)
                }

                HStack(spacing: AppSpacing.small) {
                    if !secondaryButtonTitle.isEmpty {
                        AppButton(title: secondaryButtonTitle, style: .secondary, action: onSecondary)
                    }
                    AppButton(title: primaryButtonTitle, style: primaryStyle, action: onPrimary)
                }
                .padding(.top, AppSpacing.block)
            }
            .frame(maxWidth: .infinity)
            .padding(cardPadding)

            if onClose != nil {
                Button(action: { onClose?() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.appSecondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.top, closeButtonPadding)
                .padding(.trailing, closeButtonPadding)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white)
        )
        .padding(.horizontal, AppSpacing.large)
    }
}

#Preview("AppPopUp") {
    ZStack {
        Color.appBg.ignoresSafeArea()
        Color.black.opacity(0.4)
            .ignoresSafeArea()
        AppPopUp(
            title: "Discard Changes?",
            message: "Are you sure you want to leave without saving?",
            primaryButtonTitle: "Discard",
            secondaryButtonTitle: "Keep Editing",
            primaryStyle: .destructive,
            onClose: {},
            onPrimary: {},
            onSecondary: {}
        )
    }
}
