//
//  CollectionsGalleryView.swift
//  SSC_Lab
//
//  Gallery of collections
//

import SwiftUI
import SwiftData

struct CollectionsGalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.globalToastState) private var globalToastState
    @Environment(\.hideTabBarBinding) private var hideTabBarBinding
    @Query(sort: \WinCollection.lastModified, order: .reverse) private var collections: [WinCollection]
    @Query(sort: \Win.date, order: .reverse) private var allWins: [Win]

    @State private var showAddCollectionPopUp = false
    @State private var newCollectionName = ""
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

    private var existingCollectionNames: Set<String> {
        var names = Set(collections.map { $0.name.lowercased() })
        names.insert("all")
        names.insert("all wins")
        names.insert("uncategorized")
        return names
    }

    private func isDuplicateCollectionName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return existingCollectionNames.contains(trimmed.lowercased())
    }

    /// Shown when there are no user collections. No Create button — use '+' in header.
    private var emptyStateMessage: some View {
        VStack(spacing: 16) {
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
        .padding(.vertical, 24)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                AppHeader(title: "Wins Collections") {
                    Button {
                        newCollectionName = ""
                        showAddCollectionPopUp = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.appBg)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.appPrimary))
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
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
                                    VStack(alignment: .center, spacing: 8) {
                                        CollectionCoverCard(coverImageData: item.coverImageData)
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
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg.ignoresSafeArea(.all, edges: .bottom))
            .ignoresSafeArea(.all, edges: .bottom)
            .onAppear { hideTabBarBinding?.wrappedValue = false }
            .onChange(of: showAddCollectionPopUp) { _, isShowing in
                if !isShowing { newCollectionName = "" }
            }
            .onChange(of: showRenamePopUp) { _, isShowing in
                if !isShowing {
                    collectionToRename = nil
                    renameText = ""
                }
            }
            .fullScreenCover(isPresented: $showAddCollectionPopUp) {
                addCollectionFullScreenOverlay
                    .presentationBackground(.clear)
            }
            .overlay {
                if showRenamePopUp { renamePopUpOverlay }
            }
        }
        .navigationBarHidden(true)
    }

    // Add collection
    private var addCollectionFullScreenOverlay: some View {
        let trimmed = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmpty = trimmed.isEmpty
        let isDuplicate = !isEmpty && isDuplicateCollectionName(newCollectionName)
        let canCreate = !isEmpty && !isDuplicate

        return ZStack {

            Color.black.opacity(0.4)
                .ignoresSafeArea(.all)
                .onTapGesture { showAddCollectionPopUp = false }

            VStack(spacing: 0) {
                Text("New Collection")
                    .font(.appHeroSmall)
                    .foregroundStyle(Color.appFont)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                TextField("Collection Name", text: $newCollectionName)
                    .font(.appBody)
                    .foregroundStyle(Color.appFont)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                if isDuplicate {
                    Text("A collection with this name already exists.")
                        .font(.appBodySmall)
                        .foregroundStyle(Color.appAlert)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        .padding(.horizontal, 20)
                }
                HStack(spacing: 12) {
                    AppButton(title: "Cancel", style: .secondary) {
                        showAddCollectionPopUp = false
                    }
                    AppButton(title: "Create", style: .primary) {
                        createCollection()
                        showAddCollectionPopUp = false
                    }
                    .disabled(!canCreate)
                }
                .padding(.top, 24)
            }
            .frame(maxWidth: .infinity)
            .padding(28)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appSecondary.opacity(0.4), lineWidth: 1)
            )
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
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
                            .padding(.horizontal, 32)
                        TextField("Name", text: $renameText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                        HStack(spacing: 12) {
                            AppButton(title: "Cancel", style: .secondary) {
                                showRenamePopUp = false
                            }
                            AppButton(title: "Save", style: .primary) {
                                collection.name = renameText.trimmingCharacters(in: .whitespaces)
                                try? modelContext.save()
                                showRenamePopUp = false
                            }
                            .disabled(renameText.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .padding(.top, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(RoundedRectangle(cornerRadius: 26).fill(Color.white))
                    .padding(.horizontal, 32)
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showRenamePopUp)
    }

    private func createCollection() {
        let name = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let collection = WinCollection(name: name)
        modelContext.insert(collection)
        try? modelContext.save()
    }

    private func deleteCollection(_ collection: WinCollection) {
        let name = collection.name
        let winsToRestore = Array(collection.wins)
        for win in winsToRestore {
            win.collection = nil
        }
        modelContext.delete(collection)
        try? modelContext.save()
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Win.self, WinCollection.self, configurations: config)
    CollectionsGalleryView()
        .modelContainer(container)
        .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
}
