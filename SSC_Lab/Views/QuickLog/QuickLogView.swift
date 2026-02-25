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
    @State private var viewModel = QuickLogViewModel()

    @State private var showDiscardAlert: Bool = false
    @State private var showIconPicker: Bool = false
    @State private var hasAnnouncedDuplicateInNewCollection = false
    @AccessibilityFocusState private var winTitleFocused: Bool
    @AccessibilityFocusState private var newCollectionNameFocused: Bool
    @State private var showMediaOptions: Bool = false
    @State private var showCamera: Bool = false
    @State private var showPhotoLibrarySheet: Bool = false
    @State private var imageBeforePicker: UIImage?

    private var isEditMode: Bool { winToEdit != nil }
    /// Save enabled only when image is set (required) and, for add mode, title is non-empty.
    private var canSave: Bool {
        let hasImage = viewModel.selectedUIImage != nil
        let hasTitle = !viewModel.winTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasImage && (isEditMode || hasTitle)
    }
    private let horizontalMargin: CGFloat = 16
    private let sectionSpacing: CGFloat = 30
    private let mediaBoxSize: CGFloat = 254
    private let minRowHeight: CGFloat = 44
    private let cornerRadius: CGFloat = 16

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                quickLogHeader

                Spacer().frame(height: AppSpacing.section)

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
                            environment: $viewModel.environment,
                            tools: $viewModel.tools,
                            timeframe: $viewModel.timeframe,
                            logType: $viewModel.logType
                        )
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, horizontalMargin)

                        Spacer().frame(height: sectionSpacing)

                        AppNoteEditor(text: $viewModel.quickNote, placeholder: "Add a note...")
                            .padding(.horizontal, horizontalMargin)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(viewModel.quickNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Note" : "Note. \(viewModel.quickNote)")
                            .accessibilityHint("Optional note for this win")

                        Spacer().frame(height: sectionSpacing)
                        Spacer().frame(height: AppSpacing.card)

                        AppButton(title: isEditMode ? "Save" : "Log a Win", style: .primary) {
                            if !canSave {
                                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                                return
                            }
                            performSave()
                        }
                            .disabled(!canSave)
                            .opacity(canSave ? 1 : 0.5)
                            .accessibilityHint(canSave ? "" : "Add a photo and a title to enable saving")
                            .padding(.horizontal, horizontalMargin)
                            .padding(.bottom, AppSpacing.large)
                    }
                }
                .scrollIndicators(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBg.ignoresSafeArea())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg.ignoresSafeArea())
            .accessibilityHidden(showDiscardAlert)
            .showPopUp(
                isPresented: $showDiscardAlert,
                title: Constants.Lab.discardAlertTitle,
                message: Constants.Lab.discardAlertMessage,
                primaryButtonTitle: Constants.Lab.discardAlertPrimary,
                secondaryButtonTitle: Constants.Lab.discardAlertSecondary,
                primaryStyle: .destructive,
                useGlobal: false,
                showCloseButton: false,
                onPrimary: { dismiss() },
                onSecondary: { showDiscardAlert = false }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .interactiveDismissDisabled(viewModel.hasChanges(winToEdit: winToEdit), onAttemptToDismiss: { showDiscardAlert = true })
        .confirmationDialog("Add Media", isPresented: $showMediaOptions, titleVisibility: .visible) {
            Button("Take Photo") {
                imageBeforePicker = viewModel.selectedUIImage
                showCamera = true
            }
            Button("Photo Library") {
                imageBeforePicker = viewModel.selectedUIImage
                showPhotoLibrarySheet = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose a source for your media.")
        }
        .sheet(isPresented: $showCamera, onDismiss: {
            let changed: Bool = switch (viewModel.selectedUIImage, imageBeforePicker) {
            case (nil, nil): false
            case (nil, _), (_, nil): true
            case (let a?, let b?): a !== b
            }
            if changed { viewModel.markImageAsNew() }
        }) {
            ImagePicker(sourceType: .camera, image: $viewModel.selectedUIImage)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showPhotoLibrarySheet, onDismiss: {
            let changed: Bool = switch (viewModel.selectedUIImage, imageBeforePicker) {
            case (nil, nil): false
            case (nil, _), (_, nil): true
            case (let a?, let b?): a !== b
            }
            if changed { viewModel.markImageAsNew() }
        }) {
            ImagePicker(sourceType: .photoLibrary, image: $viewModel.selectedUIImage)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showIconPicker) {
            IconPickerView(selectedIcon: $viewModel.selectedIcon)
        }
        .onChange(of: viewModel.showNewCollectionPopUp) { _, isShowing in
            if !isShowing {
                viewModel.newCollectionName = ""
                hasAnnouncedDuplicateInNewCollection = false
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { newCollectionNameFocused = true }
            }
        }
        .overlay {
            if viewModel.showNewCollectionPopUp { newCollectionPopUpOverlay }
        }
        .onChange(of: viewModel.newCollectionName) { _, _ in
            let trimmed = viewModel.newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
            let dup = !trimmed.isEmpty && collections.isDuplicateOrReservedCollectionName(viewModel.newCollectionName)
            if dup {
                if !hasAnnouncedDuplicateInNewCollection {
                    UIAccessibility.post(notification: .announcement, argument: "A collection with this name already exists.")
                    hasAnnouncedDuplicateInNewCollection = true
                }
            } else {
                hasAnnouncedDuplicateInNewCollection = false
            }
        }
        .onAppear {
            viewModel.prefill(experiment: experimentToLog, win: winToEdit, initialCollection: initialCollection)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { winTitleFocused = true }
        }
    }

    // New Collection popup  
    private var newCollectionPopUpOverlay: some View {
        let trimmed = viewModel.newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmpty = trimmed.isEmpty
        let isDuplicate = !isEmpty && collections.isDuplicateOrReservedCollectionName(viewModel.newCollectionName)
        let canCreate = !isEmpty && !isDuplicate

        return ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { viewModel.showNewCollectionPopUp = false }
            VStack(spacing: 0) {
                Text("New Collection")
                    .font(.appHeroSmall)
                    .foregroundStyle(Color.appFont)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, AppSpacing.large)
                TextField("Collection Name", text: $viewModel.newCollectionName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, AppSpacing.block)
                    .padding(.top, AppSpacing.section)
                    .accessibilityFocused($newCollectionNameFocused)
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
                        viewModel.showNewCollectionPopUp = false
                    }
                    AppButton(title: "Create", style: .primary) {
                        if !viewModel.createNewCollectionAndSelect(context: modelContext, collections: collections) {
                            globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
                        }
                    }
                    .disabled(!canCreate)
                    .accessibilityHint(canCreate ? "" : "Enter a unique collection name to enable")
                }
                .padding(.top, AppSpacing.block)
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.block)
            .background(RoundedRectangle(cornerRadius: 26).fill(Color.white))
            .padding(.horizontal, AppSpacing.large)
        }
        .makeAccessibilityModal(if: true)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.showNewCollectionPopUp)
    }

    private func performSave() {
        switch viewModel.save(context: modelContext, winToEdit: winToEdit, experimentToLog: experimentToLog) {
        case .savedAndDismiss:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            dismiss()
        case .savedSwitchToWinsAndDismiss:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            selectedTabBinding?.wrappedValue = .wins
            dismiss()
        case .saveFailed:
            globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
        }
    }

 
    private var quickLogHeader: some View {
        ZStack(alignment: .top) {
            Color.appBg.ignoresSafeArea(edges: .top)
            VStack(spacing: 0) {
                Spacer().frame(height: AppSpacing.section)
                ZStack {
                    HStack(alignment: .center, spacing: 0) {
                        Button(action: { if viewModel.hasChanges(winToEdit: winToEdit) { showDiscardAlert = true } else { dismiss() } }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.appFont)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(Color.appFont.opacity(0.05)))
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        Spacer(minLength: 0)
                        Button(action: {
                            if !canSave {
                                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                                return
                            }
                            performSave()
                        }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(Color.appPrimary))
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .disabled(!canSave)
                        .opacity(canSave ? 1 : 0.5)
                        .accessibilityLabel("Save win")
                        .accessibilityHint(canSave ? "" : "Add a photo and a title to enable saving")
                    }
                    Text(isEditMode ? "Edit Win" : "LOG A WIN")
                        .font(.appHeroSmall)
                        .foregroundStyle(Color.appFont)
                }
                .frame(height: 44)
                .padding(.horizontal, horizontalMargin)
            }
        }
        .frame(height: AppSpacing.section + 44)
    }

    //Entry Card

    private var entryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Just tried...", text: $viewModel.winTitle)
                .font(.appBodySmall)
                .foregroundStyle(Color.appFont)
                .padding(.horizontal, AppSpacing.card)
                .padding(.vertical, AppSpacing.small)
                .frame(maxWidth: .infinity)
                .frame(minHeight: minRowHeight)
                .accessibilityLabel("Win title, required")
                .accessibilityFocused($winTitleFocused)

            Divider()
                .background(Color.appSecondary)
                .padding(.horizontal, AppSpacing.card)

            HStack {
                Text("Choose Icon")
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appSecondary)
                    .accessibilityHidden(true)
                Spacer(minLength: 0)
                Button(action: { showIconPicker = true }) {
                    Image(systemName: viewModel.selectedIcon)
                        .font(.system(size: 22))
                        .foregroundStyle(Color.appPrimary)
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Choose icon, currently \(IconAccessibilityLabel.humanReadable(for: viewModel.selectedIcon))")
                .accessibilityHint("Double tap to choose your icon")
            }
            .padding(.horizontal, AppSpacing.card)
            .padding(.vertical, AppSpacing.small)
            .frame(maxWidth: .infinity)
            .frame(minHeight: minRowHeight)
            Divider()
                .background(Color.appSecondary)
                .padding(.horizontal, AppSpacing.card)

            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.appSecondary)
                        .accessibilityHidden(true)
                    Text("Collection")
                        .font(.appBodySmall)
                        .foregroundStyle(Color.appSecondary)
                        .accessibilityHidden(true)
                }
                Spacer(minLength: 0)
                Menu {
                    Button("All") {
                        viewModel.selectedCollection = nil
                    }
                    ForEach(collections) { collection in
                        Button(collection.name) {
                            viewModel.selectedCollection = collection
                        }
                    }
                    Divider()
                    Button {
                        viewModel.newCollectionName = ""
                        viewModel.showNewCollectionPopUp = true
                    } label: {
                        Label("New Collection...", systemImage: "plus")
                    }
                    .accessibilityLabel("Add new collection")
                } label: {
                    HStack(spacing: 6) {
                        Text(viewModel.selectedCollection?.name ?? "All")
                            .font(.appBodySmall)
                            .foregroundStyle(Color.appFont)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appSecondary)
                    }
                    .padding(.horizontal, AppSpacing.small)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.appShade02))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Collection, currently \(viewModel.selectedCollection?.name ?? "All")")
                .accessibilityHint("Double tap to move this win to a different collection")
            }
            .padding(.horizontal, AppSpacing.card)
            .padding(.vertical, AppSpacing.small)
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
            if let uiImage = viewModel.selectedUIImage {
                imageMenuContainer {
                    ZStack(alignment: .topTrailing) {
                        imageView(uiImage: uiImage)
                        Color.clear
                            .frame(width: mediaBoxSize, height: mediaBoxSize)
                            .contentShape(Rectangle())
                            .onTapGesture { showMediaOptions = true }
                        Button {
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut(duration: 0.2)) { viewModel.selectedUIImage = nil }
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(Circle().strokeBorder(Color.white.opacity(0.8), lineWidth: 1))
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                        .padding(AppSpacing.small)
                    }
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
                    .accessibilityHidden(true)
            }
            .frame(width: mediaBoxSize, height: mediaBoxSize)
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .clipped()
        .accessibilityLabel("Photo, required. Double tap to add photo")
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

}

// MARK: - Preview

#Preview("QuickLogView") {
    QuickLogView()
}
