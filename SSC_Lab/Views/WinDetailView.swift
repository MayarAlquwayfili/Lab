//
//  WinDetailView.swift
//  SSC_Lab
//
//  Detail view for a single Win. Layout matches ExperimentDetailView; card uses win.imageData and badges.
//

import SwiftUI
import SwiftData
import UIKit

struct WinDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.globalToastState) private var globalToastState
    @Query(sort: \WinCollection.name, order: .forward) private var collections: [WinCollection]
    @Bindable var win: Win

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    private var collectionDisplayName: String {
        win.collection?.name ?? "Uncategorized"
    }

    private let cardSize: CGFloat = 370
    private let cardBorderWidth: CGFloat = 3
    private let cardCornerRadius: CGFloat = 16
    private let topRightIconPadding: CGFloat = 8
    private let cardInternalPadding: CGFloat = 8
    private let bottomRowBadgeSpacing: CGFloat = 8
    private let badgeDimension: CGFloat = 45
    private let badgeIconDimension: CGFloat = 24
    private let scrollBottomPadding: CGFloat = 32
    private let spacingBelowCard: CGFloat = 20
    private let spacingNotesToButtons: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AppHeader(title: win.title, onBack: { dismiss() }) {
                Button(Constants.WinDetail.buttonEdit) { showEditSheet = true }
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appFont)
            }

            collectionBreadcrumb
                .padding(.top, 4)
                .padding(.bottom, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    detailCard
                        .frame(maxWidth: cardSize, maxHeight: cardSize)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)

                    AppNoteEditor(text: $win.notes, placeholder: Constants.Lab.placeholderNote)
                        .padding(.top, spacingBelowCard)

                    VStack(spacing: 12) {
                        primaryButton(title: Constants.WinDetail.buttonDoItAgain) {
                            dismiss()
                        }
                        secondaryButton(title: Constants.WinDetail.buttonDelete) {
                            showDeleteAlert = true
                        }
                    }
                    .padding(.top, spacingNotesToButtons)
                    .padding(.bottom, scrollBottomPadding)
                }
                .padding(.horizontal, Constants.WinDetail.paddingHorizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
        .toolbar(.hidden, for: .tabBar)
        .enableSwipeToBack()
        .onChange(of: win.notes) { _, _ in
            try? modelContext.save()
        }
        .sheet(isPresented: $showEditSheet) {
            WinEditSheet(win: win)
        }
        .showPopUp(
            isPresented: $showDeleteAlert,
            title: Constants.WinDetail.deletePopUpTitle,
            message: Constants.WinDetail.deletePopUpMessage,
            primaryButtonTitle: Constants.WinDetail.deletePopUpPrimary,
            secondaryButtonTitle: Constants.WinDetail.deletePopUpSecondary,
            primaryStyle: .destructive,
            showCloseButton: false,
            onPrimary: {
                modelContext.delete(win)
                try? modelContext.save()
                dismiss()
            },
            onSecondary: {
                showDeleteAlert = false
            }
        )
    }

    // MARK: - Collection breadcrumb (Menu under title)
    private var collectionBreadcrumb: some View {
        Menu {
            Button("Uncategorized") {
                moveToCollection(nil)
            }
            ForEach(collections) { collection in
                Button(collection.name) {
                    moveToCollection(collection)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(collectionDisplayName)
                    .font(.appMicro)
                    .foregroundStyle(Color.appSecondary)
                Image(systemName: "chevron.up.down")
                    .font(.appMicro)
                    .foregroundStyle(Color.appSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func moveToCollection(_ collection: WinCollection?) {
        win.collection = collection
        win.collectionName = collection?.name
        try? modelContext.save()
        let name = collection?.name ?? "Uncategorized"
        globalToastState?.show("Moved to \(name)")
    }

    // MARK: - Detail Card (image background + overlay + badges, same layout as WinCard with .large badges)
    private var detailCard: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let data = win.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color.appSecondary.opacity(0.25))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(Color.black.opacity(0.3))

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer(minLength: 0)
                    if let topIcon = topBadgeType {
                        StatusBadge(type: topIcon, size: .large, variant: .primary)
                            .padding(.top, topRightIconPadding)
                            .padding(.trailing, topRightIconPadding)
                    }
                }

                Spacer(minLength: 0)

                Text(win.title)
                    .font(.appDetailCard)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 0)

                HStack(alignment: .center, spacing: bottomRowBadgeSpacing) {
                    ForEach(bottomBadgeTypes, id: \.self) { type in
                        StatusBadge(type: type, size: .large, variant: .primary)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, cardInternalPadding)
                .padding(.bottom, cardInternalPadding)
            }
            .padding(cardInternalPadding)

            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(Color.appSecondary, lineWidth: cardBorderWidth)
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
    }

    private var topBadgeType: BadgeType? {
        [win.icon1, win.icon2, win.icon3, win.logTypeIcon]
            .compactMap { $0 }
            .first
            .flatMap { badgeType(for: $0) }
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

    // MARK: - Buttons (same style as ExperimentDetailView)
    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.appPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.appSubHeadline)
                .foregroundStyle(Color.appSecondaryDark)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.appShade02)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Edit Win Sheet (title + notes, matches experiment edit flow)
private struct WinEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var win: Win

    private let horizontalMargin: CGFloat = 16

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                TextField("Title", text: $win.title)
                    .font(.appBody)
                    .padding(.horizontal, horizontalMargin)
                    .padding(.vertical, 12)
                    .background(Color.appShade02)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, horizontalMargin)
                    .padding(.top, 16)

                AppNoteEditor(text: $win.notes, placeholder: Constants.Lab.placeholderNote)
                    .padding(.horizontal, horizontalMargin)
                    .padding(.top, 20)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg)
            .navigationTitle("Edit Win")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appFont)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        try? modelContext.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appPrimary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Win Detail") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Win.self, configurations: config)
    let win = Win(
        title: "APP STORE PUBLISH",
        imageData: nil,
        logTypeIcon: "trophy.fill",
        icon1: "apple.logo",
        icon2: "globe",
        icon3: "FINAL",
        notes: "Shipped!"
    )
    container.mainContext.insert(win)
    return NavigationStack {
        WinDetailView(win: win)
            .modelContainer(container)
    }
}
