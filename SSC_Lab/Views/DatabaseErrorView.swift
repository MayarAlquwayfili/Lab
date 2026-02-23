//
//  DatabaseErrorView.swift
//  SSC_Lab
//
//  Shown when SwiftData fails to load. Lets the user know and suggests retry/restart.
//

import SwiftUI

struct DatabaseErrorView: View {
    var body: some View {
        VStack(spacing: AppSpacing.block) {
            Image(systemName: "externaldrive.badge.exclamationmark")
                .font(.system(size: 56, weight: .medium))
                .foregroundStyle(Color.appSecondary)

            Text("Something went wrong while loading your data.")
                .font(.appBody)
                .foregroundStyle(Color.appFont)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.large)

            Text("Try closing and reopening the app. If the problem continues, try restarting your device.")
                .font(.appBodySmall)
                .foregroundStyle(Color.appSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.large)

            Spacer().frame(height: AppSpacing.card)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
    }
}

#Preview {
    DatabaseErrorView()
}
