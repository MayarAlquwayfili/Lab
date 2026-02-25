//
//  ExperimentCard.swift
//  SSC_Lab
//
//  Created by yumii on 11/02/2026.
//

import SwiftUI

struct ExperimentCard: View {
    var title: String
    var icon: String = "star.fill"
    var hasLink: Bool = false
    var topBadges: [BadgeType] = []
    var bottomBadges: [BadgeType] = []
    var size: BadgeSize = .small
    var variant: BadgeVariant = .primary
    /// When non-nil and > 1, show a small repeat badge (e.g. "x2", "x3").  
    var winCount: Int? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {

            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appSecondary, lineWidth: 1.5)


            VStack(alignment: .leading, spacing: 0) {
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
                    .padding(.top, AppSpacing.tight)
                    .padding(.trailing, AppSpacing.tight)
                }

                Spacer(minLength: 0)

                VStack {
                    Text(title)
                        .font(.appCard)
                        .foregroundStyle(Color.appPrimary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .minimumScaleFactor(0.7)
                        .lineSpacing(-2)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 12)
                .frame(height: 50, alignment: .center)
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)

                /// Bottom row
                HStack(alignment: .center, spacing: 0) {
                    StatusGroup(items: bottomBadges, size: size, variant: variant)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if hasLink {
                        StatusBadge(type: .link, size: size, variant: variant)
                            .padding(.trailing, AppSpacing.tight)
                            .padding(.bottom, AppSpacing.tight)
                    }
                }
                .padding(.top, AppSpacing.tight)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let count = winCount, count > 1 {
                Text("x\(count)")
                    .font(.appMicro)
                    .foregroundStyle(Color.appSecondary)
                    .padding(.top, 8)
                    .padding(.leading, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Experiment: \(title). Tags: \(experimentTagsAccessibilityLabel).")
        .accessibilityHint("Double tap to open experiment")
    }


    private var experimentTagsAccessibilityLabel: String {
        let fromBadges = bottomBadges.map { type in
            switch type {
            case .indoor: return "Indoor"
            case .outdoor: return "Outdoor"
            case .tools: return "Tools"
            case .noTools: return "No tools"
            case .oneTime: return "One time"
            case .newInterest: return "New interest"
            case .link: return "Reference link available"
            case .timeframe(let label): return TimeframeAccessibilityLabel.spoken(for: label)
            }
        }
        let withLink = hasLink ? fromBadges + ["Reference link available"] : fromBadges
        return withLink.isEmpty ? "(none)" : withLink.joined(separator: ", ")
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
