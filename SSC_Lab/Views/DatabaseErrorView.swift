//
//  DatabaseErrorView.swift
//  SSC_Lab
//
//  Shown when SwiftData fails to load. Lets the user know and suggests retry/restart.
//

import SwiftUI

struct DatabaseErrorView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "externaldrive.badge.exclamationmark")
                .font(.system(size: 56, weight: .medium))
                .foregroundStyle(Color.appSecondary)

            Text("Something went wrong while loading your data.")
                .font(.appBody)
                .foregroundStyle(Color.appFont)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text("Try closing and reopening the app. If the problem continues, try restarting your device.")
                .font(.appBodySmall)
                .foregroundStyle(Color.appSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer().frame(height: 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
    }
}

#Preview {
    DatabaseErrorView()
}
