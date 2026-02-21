//
//  ExperimentCard.swift
//  SSC_Lab
//
//  Created by yumii on 11/02/2026.
//

import SwiftUI

struct ExperimentCard: View {
    var title: String
    var hasLink: Bool = false
    var topBadges: [BadgeType] = []
    var bottomBadges: [BadgeType] = []
    var size: BadgeSize = .small
    var variant: BadgeVariant = .primary

    private var allBottomBadges: [BadgeType] {
        var badges = bottomBadges
        if hasLink {
            badges.append(.link)
        }
        return badges
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appSecondary, lineWidth: 1.5)

            VStack(spacing: 0) {
                // Top row: top badge (right only)
                HStack {
                    Spacer(minLength: 0)
                    if let topBadge = topBadges.first {
                        StatusBadge(type: topBadge, size: size, variant: variant)
                            .padding(8)
                    }
                }

                Spacer(minLength: 0)

                // Title centered with safe horizontal padding
                Text(title)
                    .font(.appCard)
                    .foregroundStyle(Color.appPrimary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                Spacer(minLength: 0)

                // Bottom row: StatusGroup with badges including link
                StatusGroup(items: allBottomBadges, size: size, variant: variant)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Previews
#Preview("ExperimentCard – simple") {
    ExperimentCard(
        title: "Hi",
        hasLink: false,
        topBadges: [.indoor],
        bottomBadges: [.indoor, .tools, .timeframe("1D")]
    )
    .padding()
    .background(Color.appBg)
}

#Preview("ExperimentCard – with link") {
    ExperimentCard(
        title: "ne,fsdnv lnmklw eafmklmkelwfnkknm;eqmf;kmqfk; kem;fmkmkq",
        hasLink: true,
        topBadges: [.indoor],
        bottomBadges: [.indoor, .tools, .timeframe("7D")]
    )
    .padding()
    .background(Color.appBg)
}
