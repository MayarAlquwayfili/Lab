//
//  CollectionsGalleryView.swift
//  SSC_Lab
//
//  Gallery of collections
//

import SwiftUI
import SwiftData
import UIKit
import os

struct CollectionsGalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.globalToastState) private var globalToastState
    @Environment(\.hideTabBarBinding) private var hideTabBarBinding
    @Query(sort: \WinCollection.lastModified, order: .reverse) private var collections: [WinCollection]
    @Query(sort: \Win.date, order: .reverse) private var allWins: [Win]

    @Environment(\.rootPopUpState) private var rootPopUpState
    @State private var showRenamePopUp = false
    @State private var collectionToRename: WinCollection?
    @State private var renameText = ""

    private let horizontalPadding: CGFloat = Constants.Lab.horizontalMargin
    private let gridSpacing: CGFloat = Constants.Lab.gridSpacing

    /// All card only when there is at least one win or user has custom collections.
    private var galleryItems: [GalleryGridItem] {
        let allWinsSorted = allWins.sorted { $0.date > $1.date }
        let allItem = GalleryGridItem(
            id: "all",
            title: "All",
            winCount: allWins.count,
            coverImageData: allWinsSorted.first?.imageData,
            winCollection: nil,
            isAllWins: true
        )
        var items: [GalleryGridItem] = []
        if allWins.count > 0 || !collections.isEmpty {
            items.append(allItem)
        }
        items += collections.map { collection in
            let wins = collection.wins
            let sorted = wins.sorted { $0.date > $1.date }
            return GalleryGridItem(
                id: String(describing: collection.id),
                title: collection.name,
                winCount: wins.count,
                coverImageData: sorted.first?.imageData,
                winCollection: collection,
                isAllWins: false
            )
        }
        return items
    }

    /// Show only the empty state when user has no custom collections and no wins.
    private var showEmptyStateOnly: Bool {
        collections.isEmpty && allWins.isEmpty
    }

    /// Shown when there are no user collections. No Create button — use '+' in header.
    private var emptyStateMessage: some View {
        VStack(spacing: AppSpacing.card) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(Color.appSecondary)
            Text("No Collections Yet. Tap the + button at the top to organize your wins!")
                .font(.appBodySmall)
                .foregroundStyle(Color.appFont)
                .multilineTextAlignment(.center)
                .padding(.horizontal, horizontalPadding)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.block)
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                AppHeader(title: "Wins Collections") {
                    Button {
                        guard let state = rootPopUpState else { return }
                        let data = AddCollectionPopUpData(
                            name: "",
                            isDuplicate: { name in collections.isDuplicateOrReservedCollectionName(name) },
                            onCreate: { name in
                                createCollection(named: name)
                                state.dismiss()
                            }
                        )
                        state.presentAddCollection(data)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.appBg)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.appPrimary))
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add new collection")
                }

                if showEmptyStateOnly {
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        emptyStateMessage
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: gridSpacing),
                            GridItem(.flexible(), spacing: gridSpacing)
                        ], spacing: gridSpacing) {
                            ForEach(galleryItems) { item in
                                NavigationLink(destination: CollectionDetailView(collection: item.winCollection, showAllWins: item.isAllWins)) {
                                    VStack(alignment: .center, spacing: AppSpacing.tight) {
                                        CollectionCoverCard(coverImageData: item.coverImageData)
                                            .accessibilityHidden(true)
                                        Text(item.title)
                                            .font(.appBody)
                                            .foregroundStyle(Color.appFont)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .frame(maxWidth: .infinity)
                                        Text("\(item.winCount) Wins")
                                            .font(.appMicro)
                                            .foregroundStyle(Color.appSecondary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .buttonStyle(.plain)
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel("\(item.title) Collection with \(item.winCount) wins")
                                .contextMenu {
                                    if let collection = item.winCollection, !item.isAllWins {
                                        Button {
                                            collectionToRename = collection
                                            renameText = collection.name
                                            showRenamePopUp = true
                                        } label: {
                                            Label("Rename", systemImage: "pencil.line")
                                        }
                                        Button(role: .destructive) {
                                            deleteCollection(collection)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, AppSpacing.card)
                        .padding(.bottom, AppSpacing.large)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg.ignoresSafeArea(.all, edges: .bottom))
            .ignoresSafeArea(.all, edges: .bottom)

        }
        .onAppear { hideTabBarBinding?.wrappedValue = false }
        .onChange(of: showRenamePopUp) { _, isShowing in
            if !isShowing {
                collectionToRename = nil
                renameText = ""
            }
        }
        .overlay {
            if showRenamePopUp { renamePopUpOverlay }
        }
        .navigationBarHidden(true)
    }

    // Rename popup
    private var renamePopUpOverlay: some View {
        Group {
            if showRenamePopUp, let collection = collectionToRename {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { showRenamePopUp = false }
                    VStack(spacing: 0) {
                        Text("Rename Collection")
                            .font(.appHeroSmall)
                            .foregroundStyle(Color.appFont)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, AppSpacing.large)
                        TextField("Name", text: $renameText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, AppSpacing.block)
                            .padding(.top, AppSpacing.section)
                        HStack(spacing: AppSpacing.small) {
                            AppButton(title: "Cancel", style: .secondary) {
                                showRenamePopUp = false
                            }
                            AppButton(title: "Save", style: .primary) {
                                let trimmed = renameText.trimmingCharacters(in: .whitespaces)
                                guard !trimmed.isEmpty else { return }
                                collection.name = trimmed
                                do {
                                    try modelContext.save()
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                    globalToastState?.show("Collection Renamed")
                                    showRenamePopUp = false
                                    collectionToRename = nil
                                    renameText = ""
                                } catch {
                                    Logger().error("SwiftData save failed: \(String(describing: error))")
                                    globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
                                }
                            }
                            .disabled(renameText.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .padding(.top, AppSpacing.block)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.block)
                    .background(RoundedRectangle(cornerRadius: 26).fill(Color.white))
                    .padding(.horizontal, AppSpacing.large)
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showRenamePopUp)
    }

    /// Creates a collection with the given name. Call from root Add Collection pop-up; dismiss is handled by the caller.
    private func createCollection(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !collections.isDuplicateOrReservedCollectionName(trimmed) else { return }
        let collection = WinCollection(name: trimmed)
        modelContext.insert(collection)
        do {
            try modelContext.save()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            globalToastState?.show("Collection Created")
        } catch {
            Logger().error("SwiftData save failed: \(String(describing: error))")
            globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
        }
    }

    private func deleteCollection(_ collection: WinCollection) {
        let name = collection.name
        let winsToRestore = Array(collection.wins)
        for win in winsToRestore {
            win.collection = nil
        }
        modelContext.delete(collection)
        try? modelContext.save()
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        globalToastState?.show("Collection deleted", style: .destructive, undoTitle: "Undo", onUndo: {
            let newCol = WinCollection(name: name)
            modelContext.insert(newCol)
            for w in winsToRestore {
                w.collection = newCol
            }
            try? modelContext.save()
        })
    }
}

// Grid item model
private struct GalleryGridItem: Identifiable {
    let id: String
    let title: String
    let winCount: Int
    let coverImageData: Data?
    let winCollection: WinCollection?
    let isAllWins: Bool
}

// MARK: - Preview
#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Win.self, WinCollection.self, configurations: config)
        return CollectionsGalleryView()
            .modelContainer(container)
            .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
    } catch {
        return Text("Preview failed to load")
    }
}
