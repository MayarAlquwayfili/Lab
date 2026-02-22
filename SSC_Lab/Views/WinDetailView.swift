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

    @State private var showEditSheet = false
    @State private var carouselIndex: Int = 0
    @State private var showNewCollectionPopUp = false
    @State private var newCollectionName = ""

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

                    pageIndicator
                        .padding(.top, DetailCardLayout.spacingCardToContent)

                    Text(displayedWin.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.appBodySmall)
                        .foregroundStyle(Color.appSecondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 12)

                    if !displayedWin.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(displayedWin.notes)
                            .font(.appBody.italic())
                            .foregroundStyle(Color.appFont)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)
                    }

                    VStack(spacing: 12) {
                        primaryButton(title: Constants.WinDetail.buttonDoItAgain) {
                            openDoItAgain()
                        }
                        secondaryButton(title: Constants.WinDetail.buttonDelete) {
                            deleteWinAndDismiss()
                        }
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
            }
            .sheet(isPresented: $showEditSheet) {
                QuickLogView(winToEdit: displayedWin)
            }
            .onChange(of: showNewCollectionPopUp) { _, isShowing in
                if !isShowing { newCollectionName = "" }
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
            }
            .frame(maxWidth: .infinity)

            Button(Constants.WinDetail.buttonEdit) { showEditSheet = true }
                .font(.appBodySmall)
                .foregroundStyle(Color.appFont)
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, Constants.WinDetail.paddingHorizontal)
        .padding(.top, 16)
    }

    // Carousel

    private var carouselCard: some View {
        ZStack {
            TabView(selection: $carouselIndex) {
                ForEach(Array(winsForCarousel.enumerated()), id: \.element.id) { index, w in
                    DetailCardFrame { detailCardContent(for: w) }
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
    }

    /// Card content
    private func detailCardContent(for w: Win) -> some View {
        let padding = DetailCardLayout.cardInternalPadding
        return ZStack(alignment: .center) {
            Group {
                if let data = w.imageData, let uiImage = UIImage(data: data) {
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

            RoundedRectangle(cornerRadius: DetailCardLayout.cardCornerRadius)
                .fill(Color.black.opacity(0.4))

            Text(w.title)
                .font(.appHeroOutline)
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, padding)

            VStack {
                HStack {
                    if winsForCarousel.count > 1 {
                        Text("x\(winsForCarousel.count)")
                            .font(.appMicro)
                            .foregroundStyle(Color.appSecondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.appBg.opacity(0.9)))
                    }
                    Spacer(minLength: 0)
                    if let topType = topBadgeType(for: w) {
                        StatusBadge(type: topType, size: .large, variant: .primary)
                    }
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
        let toDelete = displayedWin
        let copy = Win.copy(from: toDelete)
        let wasBoundWin = toDelete.id == win.id
        let countBefore = winsForCarousel.count
        modelContext.delete(toDelete)
        do {
            try modelContext.save()
        } catch {
            Logger().error("SwiftData save failed: \(String(describing: error))")
            modelContext.insert(copy)
            globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
            return
        }
        let remainingCount = countBefore - 1
        if remainingCount <= 0 || wasBoundWin {
            dismiss()
        } else {
            carouselIndex = min(carouselIndex, remainingCount - 1)
        }
        globalToastState?.show("Win deleted", style: .destructive, undoTitle: "Undo", onUndo: {
            modelContext.insert(copy)
            try? modelContext.save()
        })
    }

    /// Updates the currently displayed win's collection and saves. Used by the header collection Menu.
    private func moveToCollection(_ collection: WinCollection?) {
        if displayedWin.collection?.id == collection?.id {
            return
        }
        displayedWin.collection = collection
        displayedWin.collectionName = collection?.name
        collection?.lastModified = Date()
        try? modelContext.save()
        let name = collection?.name ?? "All"
        globalToastState?.show("Moved to \(name)")
    }

    private var existingCollectionNames: Set<String> {
        var names = Set(collections.map { $0.name.lowercased() })
        names.insert("all")
        names.insert("all wins")
        names.insert("uncategorized")
        return names
    }

    /// Same custom pop-up as QuickLogView: dimmed overlay, title, TextField, Create/Cancel. On Create: new collection, move win to it, toast.
    private var newCollectionPopUpOverlay: some View {
        let trimmed = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmpty = trimmed.isEmpty
        let isDuplicate = !isEmpty && existingCollectionNames.contains(trimmed.lowercased())
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
                    .padding(.horizontal, 32)
                TextField("Collection Name", text: $newCollectionName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                if isDuplicate {
                    Text("A collection with this name already exists.")
                        .font(.appBodySmall)
                        .foregroundStyle(Color.appAlert)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        .padding(.horizontal, 24)
                }
                HStack(spacing: 12) {
                    AppButton(title: "Cancel", style: .secondary) {
                        showNewCollectionPopUp = false
                    }
                    AppButton(title: "Create", style: .primary) {
                        createNewCollectionAndMove()
                    }
                    .disabled(!canCreate)
                }
                .padding(.top, 24)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(RoundedRectangle(cornerRadius: 26).fill(Color.white))
            .padding(.horizontal, 32)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showNewCollectionPopUp)
    }

    private func createNewCollectionAndMove() {
        let name = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !existingCollectionNames.contains(name.lowercased()) else { return }
        let collection = WinCollection(name: name)
        modelContext.insert(collection)
        displayedWin.collection = collection
        displayedWin.collectionName = collection.name
        collection.lastModified = Date()
        do {
            try modelContext.save()
        } catch {
            Logger().error("SwiftData save failed: \(String(describing: error))")
            globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
            return
        }
        showNewCollectionPopUp = false
        newCollectionName = ""
        globalToastState?.show("Moved to \(name)")
    }

    /// Do It Again: make the experiment active (and visible in Lab), save, switch to Home, then show QuickLogView pre-filled.
    private func openDoItAgain() {
        let exp: Experiment? = win.activityID.flatMap { id in experiments.first(where: { $0.activityID == id }) }
            ?? experiments.first(where: { $0.title == win.title })
        let target: Experiment
        if let existing = exp {
            target = existing
        } else {
            let temp = temporaryExperiment(from: win)
            modelContext.insert(temp)
            target = temp
        }
        /// Set this experiment active and not completed; deactivate all others.
        for e in experiments where e.id != target.id {
            e.isActive = false
        }
        target.isActive = true
        try? modelContext.save()
        selectedTabBinding?.wrappedValue = .home
    }

    /// Creates a temporary experiment from the Win so QuickLogView can prefill (used when original experiment was removed from Lab).
    private func temporaryExperiment(from w: Win) -> Experiment {
        let env = (w.icon1 == Constants.Icons.outdoor) ? "outdoor" : "indoor"
        let toolsStr = (w.icon2 == Constants.Icons.toolsNone) ? "none" : "required"
        let timeframeStr = w.icon3 ?? "1D"
        let logTypeStr: String? = (w.logTypeIcon == Constants.Icons.newInterest) ? "newInterest" : "oneTime"
        return Experiment(
            title: w.title,
            icon: "star.fill",
            environment: env,
            tools: toolsStr,
            timeframe: timeframeStr,
            logType: logTypeStr,
            referenceURL: "",
            labNotes: "",
            isActive: false,
            isCompleted: false,
            createdAt: .now,
            activityID: w.activityID ?? UUID()
        )
    }

    // Buttons

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
