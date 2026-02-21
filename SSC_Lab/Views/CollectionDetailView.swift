//
//  CollectionDetailView.swift
//  SSC_Lab
//
//  Detail view for a WinCollection or Uncategorized wins. Masonry grid of wins with sort/filter.
//

import SwiftUI
import SwiftData
import UIKit

enum CollectionSortOrder: String, CaseIterable {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"
}

struct CollectionDetailView: View {
    var collection: WinCollection?
    /// When true and collection is nil, show all wins. When false and collection is nil, show uncategorized only.
    var showAllWins: Bool = false

    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Win.date, order: .reverse) private var allWins: [Win]

    @State private var sortOrder: CollectionSortOrder = .newestFirst
    @State private var filterCriteria = FilterCriteria()
    @State private var showFilterSheet = false

    /// Golden margin: 16pt each side, 12pt between columns. Card width = (Screen Width - 32 - 12) / 2.
    private let horizontalPadding: CGFloat = 16
    private let columnSpacing: CGFloat = 12
    private let cardSpacing: CGFloat = 12
    private let totalHorizontalInset: CGFloat = 44  // 16 + 16 + 12

    private var collectionTitle: String {
        if showAllWins && collection == nil { return "All Wins" }
        return collection?.name ?? "Uncategorized"
    }

    private var winsInCollection: [Win] {
        if showAllWins && collection == nil {
            return Array(allWins)
        }
        if let collection = collection {
            return Array(collection.wins)
        }
        return allWins.filter { $0.collection == nil }
    }

    /// Filter by category (Indoor, Outdoor, etc.) then sort. Updates instantly when filter or sort changes.
    private var displayedWins: [Win] {
        var result = winsInCollection
        if !filterCriteria.isEmpty {
            result = result.filter { filterCriteria.matches($0) }
        }
        switch sortOrder {
        case .newestFirst:
            return result.sorted { $0.date > $1.date }
        case .oldestFirst:
            return result.sorted { $0.date < $1.date }
        }
    }

    /// Staggered grid: for every 6 items, Row1: Col1=Square, Col2=Tall | Row2: Col1=Tall, Col2=Square | Row3: Col1=Square, Col2=Square.
    /// Returns (columnIndex 0 or 1, isTall: true if tall card).
    private func columnAndStyle(forIndex index: Int) -> (column: Int, isTall: Bool) {
        switch index % 6 {
        case 0: return (0, false)  // Col1 Square
        case 1: return (1, true)    // Col2 Tall
        case 2: return (0, true)    // Col1 Tall
        case 3: return (1, false)    // Col2 Square
        case 4: return (0, false)   // Col1 Square
        case 5: return (1, false)   // Col2 Square
        default: return (0, false)
        }
    }

    /// Left column (index 0): [(Win, cardHeight)].
    private func leftColumnItems(squareHeight: CGFloat, tallHeight: CGFloat) -> [(Win, CGFloat)] {
        displayedWins.enumerated().compactMap { index, win in
            let (col, isTall) = columnAndStyle(forIndex: index)
            guard col == 0 else { return nil }
            return (win, isTall ? tallHeight : squareHeight)
        }
    }

    /// Right column (index 1): [(Win, cardHeight)].
    private func rightColumnItems(squareHeight: CGFloat, tallHeight: CGFloat) -> [(Win, CGFloat)] {
        displayedWins.enumerated().compactMap { index, win in
            let (col, isTall) = columnAndStyle(forIndex: index)
            guard col == 1 else { return nil }
            return (win, isTall ? tallHeight : squareHeight)
        }
    }

    /// True when any category filter is active or sort is not default (Newest First).
    private var hasActiveFilter: Bool {
        !filterCriteria.isEmpty || sortOrder != .newestFirst
    }

    var body: some View {
        GeometryReader { outer in
            VStack(alignment: .leading, spacing: 0) {
                AppHeader(title: collectionTitle.uppercased(), onBack: { dismiss() }) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(hasActiveFilter ? Color.appPrimary : Color.appSecondary)
                            if hasActiveFilter {
                                Circle()
                                    .fill(Color.appPrimary)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 4, y: -4)
                            }
                        }
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                if displayedWins.isEmpty {
                    if winsInCollection.isEmpty {
                        collectionDetailEmptyState
                    } else {
                        filterEmptyState
                    }
                } else {
                    ScrollView {
                        staggeredGrid(availableWidth: outer.size.width)
                    }
                    .contentMargins(.horizontal, 0, for: .scrollContent)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
        .navigationBarHidden(true)
        .enableSwipeToBack()
        .sheet(isPresented: $showFilterSheet) {
            CollectionFilterSheetView(
                allWins: winsInCollection,
                filterCriteria: $filterCriteria,
                sortOrder: $sortOrder
            )
        }
    }

    /// Staggered grid: exactly 16pt margins, 12pt between columns. Card width = (availableWidth - 44) / 2. Uses parent width so no NavigationStack/ScrollView padding affects margins.
    private func staggeredGrid(availableWidth: CGFloat) -> some View {
        let cardWidth = (availableWidth - totalHorizontalInset) / 2
        let squareHeight = cardWidth
        let tallHeight = squareHeight * 1.4
        let leftItems = leftColumnItems(squareHeight: squareHeight, tallHeight: tallHeight)
        let rightItems = rightColumnItems(squareHeight: squareHeight, tallHeight: tallHeight)

        return HStack(alignment: .top, spacing: columnSpacing) {
            VStack(alignment: .leading, spacing: cardSpacing) {
                ForEach(Array(leftItems.enumerated()), id: \.element.0.id) { _, pair in
                    let (win, h) = pair
                    NavigationLink(destination: WinDetailView(win: win)) {
                        WinCard(win: win, cardHeight: h)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: cardWidth)

            VStack(alignment: .leading, spacing: cardSpacing) {
                ForEach(Array(rightItems.enumerated()), id: \.element.0.id) { _, pair in
                    let (win, h) = pair
                    NavigationLink(destination: WinDetailView(win: win)) {
                        WinCard(win: win, cardHeight: h)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: cardWidth)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 16)
        .padding(.bottom, 32)
        .frame(width: availableWidth, alignment: .leading)
    }

    /// Empty state when 0 wins in this collection (nothing logged yet).
    private var collectionDetailEmptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(Color.appSecondary)
                Text("It's quiet in here...")
                    .font(.appBody)
                    .foregroundStyle(Color.appFont)
                    .multilineTextAlignment(.center)
                Text("Log a new win and add it here")
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, horizontalPadding)
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Empty state when filters return no results (matches Lab's filter empty state: same icon, text, Clear Filter button).
    private var filterEmptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(Color.appSecondary)
                Text("No matches found")
                    .font(.appBody)
                    .foregroundStyle(Color.appFont)
                Button {
                    filterCriteria = FilterCriteria()
                } label: {
                    Text("Clear Filter")
                        .font(.appSubHeadline)
                        .foregroundStyle(Color.appPrimary)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, horizontalPadding)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}

// MARK: - Masonry card (legacy; staggered grid uses WinCard): full image background, large yellow-stroke title, badges at bottom
struct WinMasonryCard: View {
    let win: Win
    let cardWidth: CGFloat
    let itemIndex: Int

    private let cornerRadius: CGFloat = 12
    private let badgeSize: BadgeSize = .small
    private let badgeVariant: BadgeVariant = .primary
    /// Staggered aspect ratios for masonry (0.75, 0.9, 1.05)
    private var aspectRatio: CGFloat {
        let r: [CGFloat] = [0.75, 0.9, 1.05]
        return r[itemIndex % r.count]
    }

    private var cardHeight: CGFloat { cardWidth / aspectRatio }

    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Full image background
            Group {
                if let data = win.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.appSecondary.opacity(0.25))
                        .frame(width: cardWidth, height: cardHeight)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

            // 2. Dark overlay so title and badges are readable
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // 3. Bottom stack: title (yellow stroke) above badges row on translucent background
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                strokedTitle(text: win.title)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 6)
                HStack(spacing: 6) {
                    ForEach(bottomBadgeTypes, id: \.self) { type in
                        StatusBadge(type: type, size: badgeSize, variant: badgeVariant)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .frame(width: cardWidth, height: cardHeight)
    }

    /// Yellow outline-only title (stroke, no fill) via 8-direction shadow.
    private func strokedTitle(text: String) -> some View {
        Text(text)
            .font(.appCard)
            .foregroundStyle(.clear)
            .shadow(color: .yellow, radius: 0, x: -2, y: 0)
            .shadow(color: .yellow, radius: 0, x: 2, y: 0)
            .shadow(color: .yellow, radius: 0, x: 0, y: -2)
            .shadow(color: .yellow, radius: 0, x: 0, y: 2)
            .shadow(color: .yellow, radius: 0, x: -2, y: -2)
            .shadow(color: .yellow, radius: 0, x: 2, y: -2)
            .shadow(color: .yellow, radius: 0, x: -2, y: 2)
            .shadow(color: .yellow, radius: 0, x: 2, y: 2)
    }

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

// MARK: - Win row placeholder (simple row for list; kept for reuse elsewhere)
struct WinRowView: View {
    var win: Win

    private let iconSize: CGFloat = 44
    private let cornerRadius: CGFloat = 12

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: win.logTypeIcon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.appPrimary)
                .frame(width: iconSize, height: iconSize)
                .background(Circle().fill(Color.appPrimary.opacity(0.12)))

            VStack(alignment: .leading, spacing: 4) {
                Text(win.title)
                    .font(.appBody)
                    .foregroundStyle(Color.appFont)
                    .lineLimit(2)
                Text(win.date, style: .date)
                    .font(.appMicro)
                    .foregroundStyle(Color.appSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.appSecondary)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.appSecondary.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#Preview("CollectionDetailView – with collection") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Win.self, WinCollection.self, configurations: config)
    let col = WinCollection(name: "Pottery")
    container.mainContext.insert(col)
    return NavigationStack {
        CollectionDetailView(collection: col)
            .modelContainer(container)
    }
}

#Preview("CollectionDetailView – Uncategorized") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Win.self, WinCollection.self, configurations: config)
    return NavigationStack {
        CollectionDetailView(collection: nil)
            .modelContainer(container)
    }
}
