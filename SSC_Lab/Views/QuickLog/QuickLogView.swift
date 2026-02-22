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
    @State private var showMediaOptions: Bool = false
    @State private var showCamera: Bool = false
    @State private var showPhotoLibrarySheet: Bool = false

    private var isEditMode: Bool { winToEdit != nil }
    private let horizontalMargin: CGFloat = 16
    private let sectionSpacing: CGFloat = 30
    private let mediaBoxSize: CGFloat = 254
    private let minRowHeight: CGFloat = 44
    private let cornerRadius: CGFloat = 16

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

                        Spacer().frame(height: sectionSpacing)
                        Spacer().frame(height: 16)

                        AppButton(title: isEditMode ? "Save" : "Log a Win", style: .primary) { performSave() }
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
            ImagePicker(sourceType: .camera, image: $viewModel.selectedUIImage)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showPhotoLibrarySheet) {
            ImagePicker(sourceType: .photoLibrary, image: $viewModel.selectedUIImage)
                .ignoresSafeArea()
        }
        .onChange(of: viewModel.showNewCollectionPopUp) { _, isShowing in
            if !isShowing { viewModel.newCollectionName = "" }
        }
        .overlay {
            if viewModel.showNewCollectionPopUp { newCollectionPopUpOverlay }
        }
        .onAppear { viewModel.prefill(experiment: experimentToLog, win: winToEdit, initialCollection: initialCollection) }
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
                    .padding(.horizontal, 32)
                TextField("Collection Name", text: $viewModel.newCollectionName)
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
                        viewModel.showNewCollectionPopUp = false
                    }
                    AppButton(title: "Create", style: .primary) {
                        if !viewModel.createNewCollectionAndSelect(context: modelContext, collections: collections) {
                            globalToastState?.show("Failed to save changes. Please try again.", style: .destructive)
                        }
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
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.showNewCollectionPopUp)
    }

    private func performSave() {
        switch viewModel.save(context: modelContext, winToEdit: winToEdit, experimentToLog: experimentToLog) {
        case .savedAndDismiss:
            dismiss()
        case .savedSwitchToWinsAndDismiss:
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
                Spacer().frame(height: 20)
                ZStack {
                    HStack(alignment: .center, spacing: 0) {
                        Button(action: { if viewModel.hasChanges { showDiscardAlert = true } else { dismiss() } }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.appFont)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(Color.appFont.opacity(0.05)))
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        Spacer(minLength: 0)
                        Button(action: performSave) {
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
            TextField("Just tried...", text: $viewModel.winTitle)
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
                    Image(systemName: viewModel.selectedIcon)
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
                } label: {
                    HStack(spacing: 6) {
                        Text(viewModel.selectedCollection?.name ?? "All")
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
            if let uiImage = viewModel.selectedUIImage {
                imageMenuContainer {
                    Menu {
                        Button {
                            showMediaOptions = true
                        } label: {
                            Label("Change Photo", systemImage: "photo.on.rectangle")
                        }
                        Button(role: .destructive) {
                            viewModel.selectedUIImage = nil
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

}

// MARK: - Preview

#Preview("QuickLogView") {
    QuickLogView()
}
