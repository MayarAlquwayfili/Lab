//
//  AppExperimentInputCard.swift
//  SSC_Lab
//
//

import SwiftUI

struct AppExperimentInputCard: View {
    @Binding var title: String
    @Binding var icon: String
    var onIconTap: () -> Void

    private let placeholder = "Want to try something New?"
    private let cornerRadius: CGFloat = 16
    private let minRowHeight: CGFloat = 44
    private let dividerHorizontalPadding: CGFloat = 16

    var body: some View {
        VStack(spacing: 0) {
            TextField(placeholder, text: $title)
                .font(.appBodySmall)
                .foregroundStyle(Color.appFont)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(minHeight: minRowHeight)

            Divider()
                .background(Color.appSecondary)
                .padding(.horizontal, dividerHorizontalPadding)

            HStack {
                Text("Choose Experiments Icon")
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appSecondary)
                Spacer(minLength: 0)
                Button(action: onIconTap) {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(Color.appPrimary)
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(minHeight: minRowHeight)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.appSecondary, lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview("AppExperimentInputCard") {
    struct PreviewHost: View {
        @State private var title = ""
        @State private var icon = "star.fill"
        var body: some View {
            AppExperimentInputCard(title: $title, icon: $icon, onIconTap: { })
                .padding()
                .background(Color.appBg)
        }
    }
    return PreviewHost()
}
