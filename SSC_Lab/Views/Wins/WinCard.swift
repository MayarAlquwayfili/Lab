//
//  WinCard.swift
//  SSC_Lab
//
//
//

import SwiftUI
import SwiftData
import UIKit

struct WinCard: View {
    var win: Win
    let cardHeight: CGFloat
    var cardWidth: CGFloat? = nil
    var winCount: Int? = nil
    var experimentIcon: String? = nil

    private let cornerRadius: CGFloat = 16
    private let size: BadgeSize = .small
    private let variant: BadgeVariant = .primary

    private var fixedWidth: CGFloat? { cardWidth }

    private var displayImage: UIImage? {
        guard let data = win.imageData else { return nil }
        return UIImage.downsampled(data: data, maxDimension: 400) ?? UIImage(data: data)
    }

    var body: some View {
        ZStack {
            ZStack {
                Color.clear
                if let uiImage = displayImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: fixedWidth ?? 0, maxWidth: fixedWidth ?? .infinity, minHeight: cardHeight, maxHeight: cardHeight)
                        .clipped()
                        .accessibilityHidden(true)
                } else {
                    Rectangle()
                        .fill(Color.appSecondary.opacity(0.25))
                }
            }
            .frame(minWidth: fixedWidth ?? 0, maxWidth: fixedWidth ?? .infinity, minHeight: cardHeight, maxHeight: cardHeight)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.black.opacity(0.3))

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer(minLength: 0)
                    ZStack {
                        Circle()
                            .fill(Color.appPrimary)
                        Image(systemName: experimentIcon ?? "star.fill")
                            .font(.system(size: size.iconDimension, weight: .medium))
                            .foregroundStyle(Color.appFont)
                            .frame(width: size.circleDimension, height: size.circleDimension, alignment: .center)
                    }
                    .frame(width: size.circleDimension, height: size.circleDimension)
                    .padding(.top, AppSpacing.tight)
                    .padding(.trailing, AppSpacing.tight)
                    .zIndex(1)
                }

                Spacer(minLength: 0)

                VStack {
                    Text(win.title)
                        .font(.appWin)
                        .foregroundStyle(Color.appBg)
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

                StatusGroup(items: bottomBadgeTypes, size: size, variant: variant)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, AppSpacing.tight)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.appSecondary, lineWidth: 1.5)
        }
        .frame(minWidth: fixedWidth ?? 0, maxWidth: fixedWidth ?? .infinity, minHeight: cardHeight, maxHeight: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(alignment: .topLeading) {
            if let count = winCount, count > 1 {
                Text("x\(count)")
                    .font(.appMicro)
                    .foregroundStyle(Color.appBg)
                    .padding(.top, 8)
                    .padding(.leading, 8)
            }
        }
        .contentShape(Rectangle())
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: cornerRadius))
        .layoutPriority(1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(winCardAccessibilityLabel)
        .accessibilityHint("Double tap to open win")
    }

    /// Full VoiceOver label: title, Win, tags, and optional entry count when > 1.
    private var winCardAccessibilityLabel: String {
        let countPart: String = (winCount ?? 0) > 1 ? " \(winCount!) entries." : ""
        return "\(win.title). Win. Tags: \(winTagsAccessibilityLabel).\(countPart)"
    }

    /// Badge list for VoiceOver
    private var winTagsAccessibilityLabel: String {
        let fromBadges = bottomBadgeTypes.map { type in
            switch type {
            case .indoor: return "Indoor"
            case .outdoor: return "Outdoor"
            case .tools: return "Tools"
            case .noTools: return "No tools"
            case .oneTime: return "One time"
            case .newInterest: return "New interest"
            case .link: return "Link"
            case .timeframe(let label): return TimeframeAccessibilityLabel.spoken(for: label)
            }
        }
        return fromBadges.isEmpty ? "(none)" : fromBadges.joined(separator: ", ")
    }

    /// Top badge.
    private var topBadgeType: BadgeType? {
        [win.environment, win.tools, win.timeframe, win.logTypeIcon]
            .compactMap { $0 }
            .first
            .flatMap { BadgeType.from(iconName: $0) }
    }

    /// Bottom StatusGroup.
    private var bottomBadgeTypes: [BadgeType] {
        [win.environment, win.tools, win.timeframe, win.logTypeIcon]
            .compactMap { $0 }
            .compactMap { BadgeType.from(iconName: $0) }
    }
}

// MARK: - Preview
#Preview("WinCard – Placeholder") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Win.self, configurations: config)
        let win = Win(
            title: "My First Win",
            imageData: nil,
            logTypeIcon: Constants.Icons.oneTime,
            environment: Constants.Icons.indoor,
            tools: Constants.Icons.tools,
            timeframe: "1D"
        )
        container.mainContext.insert(win)
        return WinCard(win: win, cardHeight: 181)
            .padding()
            .background(Color.appBg)
            .modelContainer(container)
    } catch {
        return Text("Preview failed to load")
    }
}
