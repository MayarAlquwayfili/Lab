//
//  CollectionsGalleryView.swift
//  SSC_Lab
//
//  Gallery of collections using AppHeader, popup style, and 2-column LazyVGrid.
//

import SwiftUI
import SwiftData

struct CollectionsGalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.globalToastState) private var globalToastState
    @Query(sort: \WinCollection.createdAt, order: .reverse) private var collections: [WinCollection]
    @Query(sort: \Win.date, order: .reverse) private var allWins: [Win]

    @State private var showAddCollectionPopUp = false
    @State private var newCollectionName = ""
    @State private var showRenamePopUp = false
    @State private var collectionToRename: WinCollection?
    @State private var renameText = ""

    private let horizontalPadding: CGFloat = Constants.Lab.horizontalMargin
    private let gridSpacing: CGFloat = Constants.Lab.gridSpacing

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
        var items: [GalleryGridItem] = [allItem]
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

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(Color.appSecondary)
                Text("No Collections Yet")
                    .font(.appBody)
                    .foregroundStyle(Color.appFont)
                    .multilineTextAlignment(.center)
                Text("Create your first collection to organize your wins.")
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, horizontalPadding)
                AppButton(title: "Create Collection", style: .primary) {
                    showAddCollectionPopUp = true
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, horizontalPadding)
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

                if galleryItems.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: gridSpacing),
                            GridItem(.flexible(), spacing: gridSpacing)
                        ], spacing: gridSpacing) {
                            ForEach(galleryItems) { item in
                                NavigationLink(destination: CollectionDetailView(collection: item.winCollection, showAllWins: item.isAllWins)) {
                                    VStack(alignment: .center, spacing: 4) {
                                        CollectionCoverCard(coverImageData: item.coverImageData)
                                        Text(item.title)
                                            .font(.appBody)
                                            .foregroundStyle(Color.appFont)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                            .frame(maxWidth: .infinity)
                                        Text("\(item.winCount) Wins")
                                            .font(.appMicro)
                                            .foregroundStyle(Color.appSecondary)
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
                                            Label("Rename", systemImage: "pencil")
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
            .background(Color.appBg)
            .onChange(of: showAddCollectionPopUp) { _, isShowing in
                if !isShowing { newCollectionName = "" }
            }
            .onChange(of: showRenamePopUp) { _, isShowing in
                if !isShowing {
                    collectionToRename = nil
                    renameText = ""
                }
            }
            .overlay {
                if showAddCollectionPopUp { addCollectionPopUpOverlay }
            }
            .overlay {
                if showRenamePopUp { renamePopUpOverlay }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Add collection popup (AppPopUp style: single Collection Name input, duplicate check)
    private var addCollectionPopUpOverlay: some View {
        let trimmed = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmpty = trimmed.isEmpty
        let isDuplicate = !isEmpty && isDuplicateCollectionName(newCollectionName)
        let canCreate = !isEmpty && !isDuplicate

        return ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { showAddCollectionPopUp = false }
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
            .padding(24)
            .background(RoundedRectangle(cornerRadius: 26).fill(Color.white))
            .padding(.horizontal, 32)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showAddCollectionPopUp)
    }

    // MARK: - Rename popup (same style as AppPopUp)
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
        for win in collection.wins {
            win.collection = nil
        }
        modelContext.delete(collection)
        try? modelContext.save()
        globalToastState?.show("Collection deleted")
    }
}

// MARK: - Grid item model
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
