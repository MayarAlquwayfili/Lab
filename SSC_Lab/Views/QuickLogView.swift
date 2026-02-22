//
//  QuickLogView.swift
//  SSC_Lab
//
//  Sheet for logging a win (from Lab with optional experiment) or editing a win (from WinDetailView).
//

import SwiftUI
import SwiftData
import UIKit
import os

struct QuickLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.globalToastState) private var globalToastState
    @Environment(\.selectedTabBinding) private var selectedTabBinding

    /// When set, prefill from this experiment (Log Win from Lab) and save creates a new Win.
    var experimentToLog: Experiment?
    /// When set, prefill from this win (Edit from WinDetailView) and save updates the existing Win.
    var winToEdit: Win?
    /// When set (e.g. opening from CollectionDetailView to add a win), this collection is pre-selected.
    var initialCollection: WinCollection?

    @Query(sort: \WinCollection.name, order: .forward) private var collections: [WinCollection]

    @State private var winTitle: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedCollection: WinCollection?
    @State private var quickNote: String = ""
    @State private var showDiscardAlert: Bool = false
    @State private var showIconPicker: Bool = false
    @State private var showMediaOptions: Bool = false
    @State private var selectedUIImage: UIImage?
    @State private var showCamera: Bool = false
    @State private var showPhotoLibrarySheet: Bool = false
    @State private var showNewCollectionPopUp: Bool = false
    @State private var newCollectionName: String = ""

    @State private var environment: EnvironmentOption = .indoor
    @State private var tools: ToolsOption = .required
    @State private var timeframe: TimeframeOption = .oneD
    @State private var logType: LogTypeOption = .oneTime

    private var isEditMode: Bool { winToEdit != nil }
    private let horizontalMargin: CGFloat = 16
    private let sectionSpacing: CGFloat = 30
    private let mediaBoxSize: CGFloat = 254
    private let minRowHeight: CGFloat = 44
    private let cornerRadius: CGFloat = 16

    private var hasChanges: Bool {
        !winTitle.isEmpty || !quickNote.isEmpty || selectedUIImage != nil
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

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                quickLogHeader

                Spacer().frame(height: 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        EmptyView().sectionHeader(title: "Just tried something New?", topSpacing: 0, horizontalPadding: horizontalMargin)
                        entryCard
                            .padding(.horizontal, horizontalMargin)

                        Spacer().frame(height: sectionSpacing)

                        mediaSection
                            .padding(.horizontal, horizontalMargin)

                        Spacer().frame(height: sectionSpacing)

                        EmptyView().sectionHeader(title: "Setup", topSpacing: 0, horizontalPadding: horizontalMargin)
                        ExperimentSetupCard(
                            showLogType: true,
                            environment: $environment,
                            tools: $tools,
                            timeframe: $timeframe,
                            logType: $logType
                        )
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, horizontalMargin)

                        Spacer().frame(height: sectionSpacing)

                        AppNoteEditor(text: $quickNote, placeholder: "Add a note...")
                            .padding(.horizontal, horizontalMargin)

                        Spacer().frame(height: sectionSpacing)
                        Spacer().frame(height: 16)

                        AppButton(title: isEditMode ? "Save" : "Log a Win", style: .primary) { saveAndDismiss() }
                            .padding(.horizontal, horizontalMargin)
                            .padding(.bottom, 32)
                    }
                }
                .scrollIndicators(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBg.ignoresSafeArea())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg.ignoresSafeArea())

            if showDiscardAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)

                AppPopUp(
                    title: Constants.Lab.discardAlertTitle,
                    message: Constants.Lab.discardAlertMessage,
                    primaryButtonTitle: Constants.Lab.discardAlertPrimary,
                    secondaryButtonTitle: Constants.Lab.discardAlertSecondary,
                    primaryStyle: .destructive,
                    onClose: nil,
                    onPrimary: { dismiss() },
                    onSecondary: { showDiscardAlert = false }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showDiscardAlert)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .confirmationDialog("Add Media", isPresented: $showMediaOptions, titleVisibility: .visible) {
            Button("Take Photo") {
                showCamera = true
            }
            Button("Photo Library") {
                showPhotoLibrarySheet = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose a source for your media.")
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera, image: $selectedUIImage)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showPhotoLibrarySheet) {
            ImagePicker(sourceType: .photoLibrary, image: $selectedUIImage)
                .ignoresSafeArea()
        }
        .onChange(of: showNewCollectionPopUp) { _, isShowing in
            if !isShowing { newCollectionName = "" }
        }
        .overlay {
            if showNewCollectionPopUp { newCollectionPopUpOverlay }
        }
        .onAppear { prefillFromSource() }
    }

    // New Collection popup  
    private var newCollectionPopUpOverlay: some View {
        let trimmed = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmpty = trimmed.isEmpty
        let isDuplicate = !isEmpty && isDuplicateCollectionName(newCollectionName)
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
                        createNewCollectionAndSelect()
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

    private func createNewCollectionAndSelect() {
        let name = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let collection = WinCollection(name: name)
        modelContext.insert(collection)
        do {
            try modelContext.save()
        } catch {
            Logger().error("SwiftData save failed: \(String(describing: error))")
            globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
            return
        }
        selectedCollection = collection
        showNewCollectionPopUp = false
    }

    private func prefillFromSource() {
        if let exp = experimentToLog {
            winTitle = exp.title
            environment = EnvironmentOption(rawValue: exp.environment) ?? .indoor
            tools = ToolsOption(rawValue: exp.tools) ?? .required
            timeframe = TimeframeOption(rawValue: exp.timeframe) ?? .oneD
            logType = LogTypeOption(rawValue: exp.logType ?? "oneTime") ?? .oneTime
        } else if let win = winToEdit {
            winTitle = win.title
            quickNote = win.notes
            selectedUIImage = win.imageData.flatMap { UIImage(data: $0) }
            selectedCollection = win.collection
            environment = (win.icon1 == Constants.Icons.outdoor) ? .outdoor : .indoor
            tools = (win.icon2 == Constants.Icons.toolsNone) ? .none : .required
            timeframe = TimeframeOption(rawValue: win.icon3 ?? "1D") ?? .oneD
            logType = (win.logTypeIcon == Constants.Icons.newInterest) ? .newInterest : .oneTime
        }
        if let initial = initialCollection, selectedCollection == nil {
            selectedCollection = initial
        }
        // When no collection selected, leave selectedCollection = nil (Gallery shows as "All"); do not create a persistent "All" collection.
    }

 
    private var quickLogHeader: some View {
        ZStack(alignment: .top) {
            Color.appBg.ignoresSafeArea(edges: .top)
            VStack(spacing: 0) {
                Spacer().frame(height: 20)
                ZStack {
                    HStack(alignment: .center, spacing: 0) {
                        Button(action: { if hasChanges { showDiscardAlert = true } else { dismiss() } }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.appFont)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(Color.appFont.opacity(0.05)))
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        Spacer(minLength: 0)
                        Button(action: saveAndDismiss) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(Color.appPrimary))
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    Text(isEditMode ? "Edit Win" : "LOG A WIN")
                        .font(.appHeroSmall)
                        .foregroundStyle(Color.appFont)
                }
                .frame(height: 44)
                .padding(.horizontal, horizontalMargin)
            }
        }
        .frame(height: 20 + 44)
    }

    //Entry Card

    private var entryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Just tried...", text: $winTitle)
                .font(.appBodySmall)
                .foregroundStyle(Color.appFont)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .frame(minHeight: minRowHeight)

            Divider()
                .background(Color.appSecondary)
                .padding(.horizontal, 16)

            HStack {
                Text("Choose Icon")
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appSecondary)
                Spacer(minLength: 0)
                Button(action: { showIconPicker = true }) {
                    Image(systemName: selectedIcon)
                        .font(.system(size: 22))
                        .foregroundStyle(Color.appPrimary)
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .frame(minHeight: minRowHeight)

            Divider()
                .background(Color.appSecondary)
                .padding(.horizontal, 16)

            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.appSecondary)
                    Text("Collection")
                        .font(.appBodySmall)
                        .foregroundStyle(Color.appSecondary)
                }
                Spacer(minLength: 0)
                Menu {
                    Button("All") {
                        selectedCollection = nil
                    }
                    ForEach(collections) { collection in
                        Button(collection.name) {
                            selectedCollection = collection
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
                    HStack(spacing: 6) {
                        Text(selectedCollection?.name ?? "All")
                            .font(.appBodySmall)
                            .foregroundStyle(Color.appFont)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.appShade02))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .frame(minHeight: minRowHeight)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.appSecondary, lineWidth: 1))
    }

    // Media Section

    private var mediaSection: some View {
        Group {
            if let uiImage = selectedUIImage {
                imageMenuContainer {
                    Menu {
                        Button {
                            showMediaOptions = true
                        } label: {
                            Label("Change Photo", systemImage: "photo.on.rectangle")
                        }
                        Button(role: .destructive) {
                            selectedUIImage = nil
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    } label: {
                        Color.clear
                            .frame(width: mediaBoxSize, height: mediaBoxSize)
                            .overlay(imageView(uiImage: uiImage))
                            .compositingGroup()
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            } else {
                imagePlaceholderButton
            }
        }
        .frame(width: mediaBoxSize, height: mediaBoxSize)
        .frame(maxWidth: .infinity)
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .clipped()
    }

    /// Wraps the image Menu so tap highlight stays rectangular (no circular liquid effect).
    @ViewBuilder
    private func imageMenuContainer<Label: View>(@ViewBuilder label: () -> Label) -> some View {
        label()
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .clipped()
    }

    private var imagePlaceholderButton: some View {
        Button(action: { showMediaOptions = true }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .foregroundStyle(Color.appSecondary)
                Text("+ Add Media")
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appSecondary)
            }
            .frame(width: mediaBoxSize, height: mediaBoxSize)
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .clipped()
    }

    private func imageView(uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(width: mediaBoxSize, height: mediaBoxSize)
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appSecondary, lineWidth: 1)
            )
    }

    // Actions

    private func saveAndDismiss() {
        let imageData = selectedUIImage?.jpegDataForStorage(compressionQuality: 0.7, maxDimension: 1024)
        let icon1 = environment == .outdoor ? Constants.Icons.outdoor : Constants.Icons.indoor
        let icon2 = tools == .none ? Constants.Icons.toolsNone : Constants.Icons.tools
        let icon3 = timeframe.rawValue
        let logTypeIcon = logType == .newInterest ? Constants.Icons.newInterest : Constants.Icons.oneTime

        if let win = winToEdit {
            win.title = winTitle.isEmpty ? "New Win" : winTitle
            win.notes = quickNote
            win.imageData = imageData
            win.icon1 = icon1
            win.icon2 = icon2
            win.icon3 = icon3
            win.logTypeIcon = logTypeIcon
            win.collection = selectedCollection
            win.collectionName = selectedCollection?.name
            win.collection?.lastModified = Date()
            do {
                try modelContext.save()
            } catch {
                Logger().error("SwiftData save failed: \(String(describing: error))")
                globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
                return
            }
            dismiss()
        } else {
            let win = Win(
                title: winTitle.isEmpty ? "New Win" : winTitle,
                imageData: imageData,
                logTypeIcon: logTypeIcon,
                icon1: icon1,
                icon2: icon2,
                icon3: icon3,
                collectionName: selectedCollection?.name,
                collection: selectedCollection,
                notes: quickNote,
                activityID: experimentToLog?.activityID
            )
            modelContext.insert(win)
            win.collection?.lastModified = Date()
            if let experiment = experimentToLog {
                experiment.isActive = false
                experiment.isCompleted = true
            }
            do {
                try modelContext.save()
            } catch {
                Logger().error("SwiftData save failed: \(String(describing: error))")
                globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
                return
            }
            selectedTabBinding?.wrappedValue = .wins
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview("QuickLogView") {
    QuickLogView()
}
