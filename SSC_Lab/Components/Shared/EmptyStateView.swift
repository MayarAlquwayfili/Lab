//
//  EmptyStateView.swift
//  SSC_Lab
//
//  Reusable empty-state 
//

import SwiftUI

struct EmptyStateView: View {
    var title: String
    var subtitle: String

    private let subtitlePadding: CGFloat = 12
    private let horizontalPadding: CGFloat = 16

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                Text(title)
                    .font(.appEmptyStateTitle)
                    .foregroundStyle(Color.appFont)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, subtitlePadding)
                    .padding(.horizontal, horizontalPadding)
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview("EmptyStateView") {
    EmptyStateView(
        title: "The Lab is ready.",
        subtitle: "What's your next experiment?"
    )
    .background(Color.appBg)
}
