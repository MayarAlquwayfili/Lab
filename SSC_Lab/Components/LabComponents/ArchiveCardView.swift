//
//  ArchiveCardView.swift
//  SSC_Lab
//
//  Card for Wins Archive grid: 181×181 image box, title, win count.
//

import SwiftUI

struct ArchiveCardView: View {
    let title: String
    let winCount: Int
    let mostRecentImageName: String?

    private let boxSize: CGFloat = 181
    private let cornerRadius: CGFloat = 12
    private let borderWidth: CGFloat = 1
    private let spacingBelowImage: CGFloat = 4
    private let spacingBelowTitle: CGFloat = 4

    var body: some View {
        VStack(spacing: 0) {
            // Image/Box: 181×181, rounded corners, border
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.appShade02)
                    .frame(width: boxSize, height: boxSize)
                if let name = mostRecentImageName, !name.isEmpty {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                        .frame(width: boxSize, height: boxSize)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                } else {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(Color.appSecondary)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.appSecondary.opacity(0.5), lineWidth: borderWidth)
            )
            .frame(width: boxSize, height: boxSize)

            Spacer().frame(height: spacingBelowImage)

            Text(title)
                .font(.appBodySmall)
                .foregroundStyle(Color.appFont)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Spacer().frame(height: spacingBelowTitle)

            Text("\(winCount) Wins")
                .font(.appMicro)
                .foregroundStyle(Color.appSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: boxSize)
    }
}

#Preview("ArchiveCardView – with image") {
    ArchiveCardView(title: "Pottery", winCount: 10, mostRecentImageName: nil)
        .padding()
        .background(Color.appBg)
}

#Preview("ArchiveCardView – placeholder") {
    ArchiveCardView(title: "Uncategorized", winCount: 0, mostRecentImageName: nil)
        .padding()
        .background(Color.appBg)
}
