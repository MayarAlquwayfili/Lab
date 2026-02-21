//
//  WinCard.swift
//  SSC_Lab
//
//  Exact same layout as ExperimentCard; only difference is background image + overlay.
//

import SwiftUI
import SwiftData
import UIKit

struct WinCard: View {
    var win: Win
    let cardHeight: CGFloat

    private let cornerRadius: CGFloat = 16
    private let size: BadgeSize = .small
    private let variant: BadgeVariant = .primary

    var body: some View {
        ZStack {
            // 1. Background: Image from win.imageData or placeholder
            Group {
                if let data = win.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, minHeight: cardHeight, maxHeight: cardHeight)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.appSecondary.opacity(0.25))
                        .frame(maxWidth: .infinity, minHeight: cardHeight, maxHeight: cardHeight)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

            // 2. Overlay so white text/badges are clear
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.black.opacity(0.3))

            // 3. Content — same ZStack/VStack structure as ExperimentCard
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer(minLength: 0)
                    if let topIcon = topBadgeType {
                        StatusBadge(type: topIcon, size: size, variant: variant)
                            .padding(.top, 8)
                            .padding(.trailing, 8)
                    }
                }

                Spacer(minLength: 0)

                Text(win.title)
                    .font(.appWin)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 0)

                StatusGroup(items: bottomBadgeTypes, size: size, variant: variant)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
            }

            // 4. Stroke border (same as ExperimentCard)
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.appSecondary, lineWidth: 1.5)
        }
        .frame(maxWidth: .infinity, minHeight: cardHeight, maxHeight: cardHeight)
    }

    /// First icon from win model → top badge.
    private var topBadgeType: BadgeType? {
        [win.icon1, win.icon2, win.icon3, win.logTypeIcon]
            .compactMap { $0 }
            .first
            .flatMap { badgeType(for: $0) }
    }

    /// All 4 icons (icon1, icon2, icon3, logTypeIcon) for bottom StatusGroup.
    private var bottomBadgeTypes: [BadgeType] {
        [win.icon1, win.icon2, win.icon3, win.logTypeIcon]
            .compactMap { $0 }
            .compactMap { badgeType(for: $0) }
    }

    private func badgeType(for iconName: String) -> BadgeType? {
        switch iconName {
        case Constants.Icons.indoor: return .indoor
        case Constants.Icons.outdoor: return .outdoor
        case Constants.Icons.tools: return .tools
        case Constants.Icons.toolsNone: return .noTools
        case Constants.Icons.oneTime: return .oneTime
        case Constants.Icons.newInterest: return .newInterest
        default:
            if iconName == "1D" || iconName == "7D" || iconName == "30D" || iconName == "+30D" {
                return .timeframe(iconName)
            }
            return nil
        }
    }
}

// MARK: - Preview
#Preview("WinCard – Placeholder") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Win.self, configurations: config)
    let win = Win(
        title: "My First Win",
        imageData: nil,
        logTypeIcon: Constants.Icons.oneTime,
        icon1: Constants.Icons.indoor,
        icon2: Constants.Icons.tools,
        icon3: "1D"
    )
    container.mainContext.insert(win)
    return WinCard(win: win, cardHeight: 181)
        .padding()
        .background(Color.appBg)
        .modelContainer(container)
}
