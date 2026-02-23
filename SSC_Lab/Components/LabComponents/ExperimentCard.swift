//
//  ExperimentCard.swift
//  SSC_Lab
//
//  Created by yumii on 11/02/2026.
//

import SwiftUI

struct ExperimentCard: View {
    var title: String
    /// SF Symbol name for the experiment (e.g. "star.fill"). Shown in the top-right badge.
    var icon: String = "star.fill"
    var hasLink: Bool = false
    var topBadges: [BadgeType] = []
    var bottomBadges: [BadgeType] = []
    var size: BadgeSize = .small
    var variant: BadgeVariant = .primary
    /// When non-nil and > 1, show a small repeat badge (e.g. "x2", "x3"). First win is standard; we only show repeats.
    var winCount: Int? = nil

    private var allBottomBadges: [BadgeType] {
        var badges = bottomBadges
        if hasLink {
            badges.append(.link)
        }
        return badges
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appSecondary, lineWidth: 1.5)

            VStack(spacing: 0) {
                // Top row: experiment icon in top-right badge
                HStack {
                    Spacer(minLength: 0)
                    ZStack {
                        Circle()
                            .fill(Color.appPrimary)
                        Image(systemName: icon)
                            .font(.system(size: size.iconDimension, weight: .medium))
                            .foregroundStyle(Color.appFont)
                            .frame(width: size.circleDimension, height: size.circleDimension, alignment: .center)
                    }
                    .frame(width: size.circleDimension, height: size.circleDimension)
                    .padding(AppSpacing.tight)
                }

                Spacer(minLength: 0)

                Text(title)
                    .font(.appCard)
                    .foregroundStyle(Color.appPrimary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.card)

                Spacer(minLength: 0)

                // Bottom row
                StatusGroup(items: allBottomBadges, size: size, variant: variant)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let count = winCount, count > 1 {
                Text("x\(count)")
                    .font(.appMicro)
                    .foregroundStyle(Color.appSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.appBg.opacity(0.9)))
                    .padding(AppSpacing.tight)
            }
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
