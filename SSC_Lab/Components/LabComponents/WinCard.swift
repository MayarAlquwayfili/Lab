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
    /// When set (e.g. from masonry grid), card and image are strictly constrained to this width to prevent overflow.
    var cardWidth: CGFloat? = nil
    /// When > 1, shows a repeat badge (e.g. "x2") in the top-left corner.
    var winCount: Int? = nil
    /// When set, show this SF Symbol in the top-right badge (e.g. experiment icon). Otherwise fall back to status badge.
    var experimentIcon: String? = nil

    private let cornerRadius: CGFloat = 16
    private let size: BadgeSize = .small
    private let variant: BadgeVariant = .primary

    /// When cardWidth is set, fixes width; otherwise allows flexible width (e.g. in detail view).
    private var fixedWidth: CGFloat? { cardWidth }

    var body: some View {
        ZStack {
            // 1. Background: Image
            ZStack {
                Color.clear
                if let data = win.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color.appSecondary.opacity(0.25))
                }
            }
            .frame(minWidth: fixedWidth ?? 0, maxWidth: fixedWidth ?? .infinity, minHeight: cardHeight, maxHeight: cardHeight)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

            // 2. Overlay so white text/badges are clear
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.black.opacity(0.3))

            // 3. Content
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    if let count = winCount, count > 1 {
                        Text("x\(count)")
                            .font(.appMicro)
                            .foregroundStyle(Color.appSecondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.appBg.opacity(0.9)))
                            .padding(AppSpacing.tight)
                    }
                    Spacer(minLength: 0)
                    // Always show experiment icon badge (same styling as Lab): solid appPrimary circle, appFont icon
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

                Text(win.title)
                    .font(.appWin)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 0)

                StatusGroup(items: bottomBadgeTypes, size: size, variant: variant)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, AppSpacing.tight)
            }

            // 4. Stroke border
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.appSecondary, lineWidth: 1.5)
        }
        .frame(minWidth: fixedWidth ?? 0, maxWidth: fixedWidth ?? .infinity, minHeight: cardHeight, maxHeight: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .contentShape(Rectangle())
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: cornerRadius))
        .layoutPriority(1)
    }

    /// Top badge.
    private var topBadgeType: BadgeType? {
        [win.icon1, win.icon2, win.icon3, win.logTypeIcon]
            .compactMap { $0 }
            .first
            .flatMap { BadgeType.from(iconName: $0) }
    }

    /// Bottom StatusGroup.
    private var bottomBadgeTypes: [BadgeType] {
        [win.icon1, win.icon2, win.icon3, win.logTypeIcon]
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
            icon1: Constants.Icons.indoor,
            icon2: Constants.Icons.tools,
            icon3: "1D"
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
