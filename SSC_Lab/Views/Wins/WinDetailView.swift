//
//  WinDetailView.swift
//  SSC_Lab
//
//  Detail view for a single Win.
//

import SwiftUI
import SwiftData
import UIKit
import os

struct WinDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.globalToastState) private var globalToastState
    @Environment(\.hideTabBarBinding) private var hideTabBarBinding
    @Environment(\.selectedTabBinding) private var selectedTabBinding
    @Query(sort: \WinCollection.name, order: .forward) private var collections: [WinCollection]
    @Query(sort: \Win.date, order: .reverse) private var allWins: [Win]
    @Query(sort: \Experiment.createdAt, order: .reverse) private var experiments: [Experiment]
    @Bindable var win: Win

    @State private var viewModel = WinDetailViewModel()
    @State private var showEditSheet = false
    @State private var carouselIndex: Int = 0
    @State private var showNewCollectionPopUp = false
    @State private var newCollectionName = ""
    @AccessibilityFocusState private var detailFocused: Bool
    @State private var hasAnnouncedDuplicateInNewCollection = false

    /// Carousel: all wins with the same activityID (only). If no activityID, single card.
    private var winsForCarousel: [Win] {
        guard let id = win.activityID else { return [win] }
        let list = allWins.filter { $0.activityID == id }
        return list.isEmpty ? [win] : list
    }

    /// The win currently shown (drives notes, date, and which iteration is displayed).
    private var displayedWin: Win {
        let list = winsForCarousel
        guard !list.isEmpty, carouselIndex >= 0, carouselIndex < list.count else { return win }
        return list[carouselIndex]
    }

    private var collectionDisplayName: String {
        displayedWin.collection?.name ?? "All"
    }

    /// Icon for the win: use win.icon when set, else resolve from linked experiment (activityID or title); fallback "star.fill".
    private func experimentIcon(for w: Win) -> String {
        if let icon = w.icon, !icon.isEmpty { return icon }
        if let id = w.activityID,
           let exp = experiments.first(where: { $0.activityID == id }) {
            return exp.icon
        }
        if let exp = experiments.first(where: { $0.title == w.title }) {
            return exp.icon
        }
        return "star.fill"
    }

    private let bottomRowBadgeSpacing: CGFloat = 8
    private let dotSize: CGFloat = 8
    private let dotSpacing: CGFloat = 6

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea(.all, edges: .bottom)

            VStack(alignment: .leading, spacing: 0) {
                winDetailHeader

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        carouselCard
                        .frame(height: DetailCardLayout.cardSize)
                        .frame(maxWidth: .infinity)
                        .padding(.top, DetailCardLayout.spacingHeaderToCard)
                        .accessibilityFocused($detailFocused)

                    if winsForCarousel.count > 1 {
                        pageIndicator
                            .padding(.top, DetailCardLayout.spacingCardToContent)
                    }

                    Text(displayedWin.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.appBodySmall)
                        .foregroundStyle(Color.appSecondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, AppSpacing.small)

                    if !displayedWin.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(displayedWin.notes)
                            .font(.appBody.italic())
                            .foregroundStyle(Color.appFont)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, AppSpacing.small)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Notes. \(displayedWin.notes)")
                    }

                    VStack(spacing: AppSpacing.small) {
                        AppButton(title: Constants.WinDetail.buttonDoItAgain, style: .primary) {
                            openDoItAgain()
                        }
                        .accessibilityHint("Double tap to do this again and switch to Lab")
                        AppButton(title: Constants.WinDetail.buttonDelete, style: .secondary) {
                            deleteWinAndDismiss()
                        }
                        .accessibilityHint("Double tap to delete this win")
                    }
                        .padding(.top, DetailCardLayout.spacingContentToButtons)
                        .padding(.bottom, Constants.WinDetail.scrollBottomPadding)
                    }
                    .padding(.horizontal, Constants.WinDetail.paddingHorizontal)
                }
                .scrollIndicators(.hidden)
                .ignoresSafeArea(.all, edges: .bottom)
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .toolbar(.hidden, for: .tabBar)
            .toolbarBackground(.hidden, for: .tabBar)
            .persistentSystemOverlays(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg.ignoresSafeArea(.all, edges: [.top, .bottom]))
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationBarBackButtonHidden(true)
            .enableSwipeToBack()
            .onAppear {
                var t = Transaction()
                t.disablesAnimations = true
                withTransaction(t) {
                    hideTabBarBinding?.wrappedValue = true
                }
                if let idx = winsForCarousel.firstIndex(where: { $0.id == win.id }) {
                    carouselIndex = idx
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { detailFocused = true }
            }
            .sheet(isPresented: $showEditSheet) {
                QuickLogView(winToEdit: displayedWin)
            }
            .onChange(of: showNewCollectionPopUp) { _, isShowing in
                if !isShowing { newCollectionName = ""; hasAnnouncedDuplicateInNewCollection = false }
            }
            .onChange(of: newCollectionName) { _, _ in
                let dup = !newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && collections.isDuplicateOrReservedCollectionName(newCollectionName)
                if dup {
                    if !hasAnnouncedDuplicateInNewCollection {
                        UIAccessibility.post(notification: .announcement, argument: "A collection with this name already exists.")
                        hasAnnouncedDuplicateInNewCollection = true
                    }
                } else {
                    hasAnnouncedDuplicateInNewCollection = false
                }
            }
            .overlay {
                if showNewCollectionPopUp { newCollectionPopUpOverlay }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }

    // Header
    private var winDetailHeader: some View {
        HStack(alignment: .center, spacing: 0) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appFont)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.appFont.opacity(0.05)))
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)

            VStack(spacing: 4) {
                Text(displayedWin.title)
                    .font(.appHeroSmall)
                    .foregroundStyle(Color.appFont)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.center)
                Menu {
                    Button("All") {
                        moveToCollection(nil)
                    }
                    ForEach(collections) { collection in
                        Button(collection.name) {
                            moveToCollection(collection)
                        }
                    }
                    Divider()
                    Button {
                        newCollectionName = ""
                        showNewCollectionPopUp = true
                    } label: {
                        Label("New Collection...", systemImage: "plus")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(collectionDisplayName)
                            .font(.appCaption)
                            .foregroundStyle(Color.appSecondary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.appSecondary.opacity(0.5))
                    }
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.2), value: collectionDisplayName)
                .accessibilityLabel("Collection, \(collectionDisplayName)")
                .accessibilityHint("Double tap to move this win to a different collection")
            }
            .frame(maxWidth: .infinity)

            Button(Constants.WinDetail.buttonEdit) { showEditSheet = true }
                .font(.appBodySmall)
                .foregroundStyle(Color.appFont)
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, Constants.WinDetail.paddingHorizontal)
        .padding(.top, AppSpacing.card)
    }

    // Carousel

    private var carouselCard: some View {
        ZStack {
            TabView(selection: $carouselIndex) {
                ForEach(Array(winsForCarousel.enumerated()), id: \.element.id) { index, w in
                    DetailCardFrame { detailCardContent(for: w, carouselIndex: index) }
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .toolbar(.hidden, for: .tabBar)
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private var pageIndicator: some View {
        HStack(spacing: dotSpacing) {
            ForEach(0..<winsForCarousel.count, id: \.self) { index in
                Circle()
                    .fill(index == carouselIndex ? Color.appPrimary : Color.appSecondary.opacity(0.4))
                    .frame(width: dotSize, height: dotSize)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(carouselIndex + 1) of \(winsForCarousel.count)")
        .accessibilityHint("Swipe left or right with three fingers to change win")
    }

    /// Card content
    private func detailCardContent(for w: Win, carouselIndex index: Int) -> some View {
        let padding = DetailCardLayout.cardInternalPadding
        let total = winsForCarousel.count
        return ZStack(alignment: .center) {
            Group {
                if let data = w.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .accessibilityHidden(true)
                } else {
                    Rectangle()
                        .fill(Color.appSecondary.opacity(0.25))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

            RoundedRectangle(cornerRadius: DetailCardLayout.cardCornerRadius)
                .fill(Color.black.opacity(0.4))

            VStack {
                Text(w.title)
                    .font(.appHeroOutline)
                    .foregroundStyle(Color.appBg)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.7)
                    .lineSpacing(-2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(height: 50, alignment: .center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, padding)

            VStack {
                HStack {
                    Spacer(minLength: 0)
                    // Experiment icon badge (same as Lab): solid appPrimary circle, appFont icon
                    ZStack {
                        Circle()
                            .fill(Color.appPrimary)
                        Image(systemName: experimentIcon(for: w))
                            .font(.system(size: BadgeSize.large.iconDimension, weight: .medium))
                            .foregroundStyle(Color.appFont)
                            .frame(width: BadgeSize.large.circleDimension, height: BadgeSize.large.circleDimension, alignment: .center)
                    }
                    .frame(width: BadgeSize.large.circleDimension, height: BadgeSize.large.circleDimension)
                    .zIndex(1)
                }
                .padding(.top, padding)
                .padding(.leading, padding)
                .padding(.trailing, padding)
                Spacer(minLength: 0)
                HStack(alignment: .center, spacing: bottomRowBadgeSpacing) {
                    ForEach(bottomBadgeTypes(for: w), id: \.self) { type in
                        StatusBadge(type: type, size: .large, variant: .primary)
                    }
                    Spacer(minLength: 0)
                    if let logType = logTypeBadgeType(for: w) {
                        StatusBadge(type: logType, size: .large, variant: .primary)
                    }
                }
                .padding(.horizontal, padding)
                .padding(.bottom, padding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .overlay(alignment: .topLeading) {
            if winsForCarousel.count > 1 {
                Text("x\(winsForCarousel.count)")
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appBg)
                    .padding(.top, 12)
                    .padding(.leading, 12)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(detailCardAccessibilityLabel(for: w, carouselIndex: index))
    }

    /// VoiceOver label for the detail card: "[Title]. Win. [Date]. Tags: [badge list]. [X] of [Y]" (X of Y only when multiple).
    private func detailCardAccessibilityLabel(for w: Win, carouselIndex index: Int) -> String {
        let dateStr = w.date.formatted(date: .abbreviated, time: .omitted)
        let tags = detailCardTagsAccessibilityLabel(for: w)
        let pagePart = winsForCarousel.count > 1 ? " \(index + 1) of \(winsForCarousel.count)" : ""
        return "\(w.title). Win. \(dateStr). Tags: \(tags).\(pagePart)"
    }

    /// Human-readable badge list for VoiceOver (same mapping as ExperimentDetailView / WinCard).
    private func detailCardTagsAccessibilityLabel(for w: Win) -> String {
        var types = bottomBadgeTypes(for: w)
        if let logType = logTypeBadgeType(for: w) { types.append(logType) }
        let fromBadges = types.map { type in
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

     private func topBadgeType(for w: Win) -> BadgeType? {
        [w.icon1, w.icon2, w.icon3, w.logTypeIcon]
            .compactMap { $0 }
            .first
            .flatMap { BadgeType.from(iconName: $0) }
    }

     private func bottomBadgeTypes(for w: Win) -> [BadgeType] {
        [w.icon1, w.icon2, w.icon3]
            .compactMap { $0 }
            .compactMap { BadgeType.from(iconName: $0) }
    }

    private func logTypeBadgeType(for w: Win) -> BadgeType? {
        guard !w.logTypeIcon.isEmpty else { return nil }
        return BadgeType.from(iconName: w.logTypeIcon) ?? .oneTime
    }

    // Actions

    private func deleteWinAndDismiss() {
        let (outcome, undo) = viewModel.deleteWin(
            displayedWin: displayedWin,
            boundWinId: win.id,
            winsForCarouselCount: winsForCarousel.count,
            currentCarouselIndex: carouselIndex,
            context: modelContext
        )
        if let outcome {
            switch outcome {
            case .dismiss:
                dismiss()
            case .stay(let newIndex):
                carouselIndex = newIndex
            }
            globalToastState?.show("Win deleted", style: .destructive, undoTitle: "Undo", onUndo: undo)
        } else {
            globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
        }
    }

    /// Updates the currently displayed win's collection and saves. Used by the header collection Menu.
    private func moveToCollection(_ collection: WinCollection?) {
        if displayedWin.collection?.id == collection?.id {
            return
        }
        if viewModel.moveToCollection(displayedWin: displayedWin, collection: collection, context: modelContext) {
            let name = collection?.name ?? "All"
            globalToastState?.show("Moved to \(name)", autoHideSeconds: 1.5)
        } else {
            globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
        }
    }

    /// Same custom pop-up as QuickLogView: dimmed overlay, title, TextField, Create/Cancel. On Create: new collection, move win to it, toast.
    private var newCollectionPopUpOverlay: some View {
        let trimmed = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmpty = trimmed.isEmpty
        let isDuplicate = !isEmpty && collections.isDuplicateOrReservedCollectionName(newCollectionName)
        let canCreate = !isEmpty && !isDuplicate

        return ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { showNewCollectionPopUp = false }
            VStack(spacing: 0) {
                Text("New Collection")
                    .font(.appHeroSmall)
                    .foregroundStyle(Color.appFont)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, AppSpacing.large)
                TextField("Collection Name", text: $newCollectionName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, AppSpacing.block)
                    .padding(.top, AppSpacing.section)
                if isDuplicate {
                    Text("A collection with this name already exists.")
                        .font(.appBodySmall)
                        .foregroundStyle(Color.appAlert)
                        .multilineTextAlignment(.center)
                        .padding(.top, AppSpacing.tight)
                        .padding(.horizontal, AppSpacing.block)
                }
                HStack(spacing: AppSpacing.small) {
                    AppButton(title: "Cancel", style: .secondary) {
                        showNewCollectionPopUp = false
                    }
                    AppButton(title: "Create", style: .primary) {
                        if let name = viewModel.createNewCollectionAndMove(
                            displayedWin: displayedWin,
                            name: newCollectionName,
                            collections: collections,
                            context: modelContext
                        ) {
                            showNewCollectionPopUp = false
                            newCollectionName = ""
                            globalToastState?.show("Moved to \(name)", autoHideSeconds: 1.5)
                        } else {
                            globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
                        }
                    }
                    .disabled(!canCreate)
                }
                .padding(.top, AppSpacing.block)
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.block)
            .background(RoundedRectangle(cornerRadius: 26).fill(Color.white))
            .padding(.horizontal, AppSpacing.large)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showNewCollectionPopUp)
    }

    /// Do It Again: make the experiment active, save, switch to Home (QuickLogView can then be presented).
    private func openDoItAgain() {
        viewModel.openDoItAgain(win: win, experiments: experiments, context: modelContext) {
            selectedTabBinding?.wrappedValue = .home
        }
    }
}

// MARK: - Preview

#Preview("Win Detail") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Win.self, configurations: config)
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
    } catch {
        return Text("Preview failed to load")
    }
}
