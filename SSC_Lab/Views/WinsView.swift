//
//  WinsView.swift
//  SSC_Lab
//
//  WINS ARCHIVE: list of Win cards from SwiftData, sorted by date (newest first).
//

import SwiftUI
import SwiftData
import UIKit

struct WinsView: View {
    @Query(sort: \Win.date, order: .reverse) private var wins: [Win]

    private let horizontalMargin: CGFloat = 16
    private let cardCornerRadius: CGFloat = 16

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                AppHeader(title: "WINS ARCHIVE")

                ScrollView {
                    if wins.isEmpty {
                        EmptyStateView(
                            title: "No breakthroughs yet",
                            subtitle: "Start experimenting!"
                        )
                            .padding(.horizontal, horizontalMargin)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(wins) { win in
                                NavigationLink(destination: WinDetailView(win: win)) {
                                    WinArchiveCard(win: win)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, horizontalMargin)
                        .padding(.vertical, 16)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - White list card (icon, title, optional thumbnail, collection tag)

private struct WinArchiveCard: View {
    var win: Win

    private let cardCornerRadius: CGFloat = 16
    private let iconSize: CGFloat = 44
    private let thumbnailSize: CGFloat = 56

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

                if let collection = win.collectionName, !collection.isEmpty {
                    Text(collection)
                        .font(.appMicro)
                        .foregroundStyle(Color.appSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.appSecondary.opacity(0.15)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let data = win.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: thumbnailSize, height: thumbnailSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(Color.appSecondary, lineWidth: 1)
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Win.self, configurations: config)
    return WinsView()
        .modelContainer(container)
}
