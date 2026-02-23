//
//  AppButton.swift
//  SSC_Lab
//
//  Created by yumii on 13/02/2026.
//

import SwiftUI

// Button style
enum AppButtonStyle {
    case primary
    case secondary
    case destructive


    var backgroundColor: Color {
        switch self {
        case .primary: return Color.appPrimary
        case .secondary: return Color.appSecondary
        case .destructive: return Color.appAlert

        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary: return Color.white
        case .secondary: return .appFont
        case .destructive: return Color.white

        }
    }
}

// AppButton
struct AppButton: View {
    var title: String
    var style: AppButtonStyle = .primary
    var action: () -> Void

    private let cornerRadius: CGFloat = 16

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appSubHeadline)
                .foregroundStyle(style.foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.card)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(style.backgroundColor)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews
#Preview("AppButton – Primary") {
    AppButton(title: "Primary Button", style: .primary) {}
        .padding(.horizontal, AppSpacing.block)
        .padding(.vertical, AppSpacing.section)
        .background(Color.appBg)
}

#Preview("AppButton – Secondary") {
    AppButton(title: "Secondary Button", style: .secondary) {}
        .padding(.horizontal, AppSpacing.block)
        .padding(.vertical, AppSpacing.section)
        .background(Color.appBg)
}

#Preview("AppButton – Destructive") {
    AppButton(title: "Destructive Button", style: .destructive) {}
        .padding(.horizontal, AppSpacing.block)
        .padding(.vertical, AppSpacing.section)
        .background(Color.appBg)
}

#Preview("AppButton – Both styles") {
    VStack(spacing: AppSpacing.card) {
        AppButton(title: "Primary", style: .primary) {}
        AppButton(title: "Secondary", style: .secondary) {}
        AppButton(title: "Destructive", style: .destructive) {}

    }
    .padding(AppSpacing.block)
    .background(Color.appBg)
}
