//
//  QuickLogView.swift
//  SSC_Lab
//
//  Sheet for logging a win
//

import SwiftUI
import SwiftData
import PhotosUI

struct QuickLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var winTitle: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedCollection: String?
    @State private var quickNote: String = ""
    @State private var showDiscardAlert: Bool = false
    @State private var showIconPicker: Bool = false
    @State private var showMediaOptions: Bool = false
    @State private var photoLibraryItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    @State private var showCamera: Bool = false
    @State private var showPhotoLibrarySheet: Bool = false

    private let collections = ["Summer 20", "Chapter 19"]
    private let horizontalMargin: CGFloat = 16
    private let sectionSpacing: CGFloat = 30
    private let mediaBoxSize: CGFloat = 254
    private let minRowHeight: CGFloat = 44
    private let cornerRadius: CGFloat = 16

    private var hasChanges: Bool {
        !winTitle.isEmpty || !quickNote.isEmpty || selectedUIImage != nil
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
                        ExperimentSetupCard(showLogType: true)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, horizontalMargin)

                        Spacer().frame(height: sectionSpacing)

                        AppNoteEditor(text: $quickNote, placeholder: "Add a note...")
                            .padding(.horizontal, horizontalMargin)

                        Spacer().frame(height: sectionSpacing)
                        Spacer().frame(height: 16)

                        AppButton(title: "Log a Win", style: .primary) { saveAndDismiss() }
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
            CameraImagePicker(image: $selectedUIImage)
                .ignoresSafeArea()
        }
        .photosPicker(
            isPresented: $showPhotoLibrarySheet,
            selection: $photoLibraryItem,
            matching: .images
        )
        .onChange(of: photoLibraryItem) { _, newItem in
            Task {
                guard let newItem else { return }
                if let data = try? await newItem.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                    await MainActor.run { selectedUIImage = uiImage }
                }
            }
        }
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
                    Text("LOG A WIN")
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
                Text("Collection")
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appSecondary)
                Spacer(minLength: 0)
                Menu {
                    ForEach(collections, id: \.self) { name in
                        Button(name) { selectedCollection = name }
                    }
                    Divider()
                    Button {
                        // Add New Collection action
                    } label: {
                        Label {
                            Text("Add New...")
                        } icon: {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedCollection ?? "Choose")
                            .font(.appBodySmall)
                            .foregroundStyle(Color.appFont)
                        Image(systemName: selectedCollection == nil ? "chevron.right" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appSecondary)
                    }
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
        ZStack {
            if let uiImage = selectedUIImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: mediaBoxSize, height: mediaBoxSize)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.appSecondary, lineWidth: 1)
                    )
                    .overlay(alignment: .topTrailing) {
                        Button(action: { selectedUIImage = nil; photoLibraryItem = nil }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 28, height: 28)
                                .background(Circle().fill(Color.appFont.opacity(0.7)))
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                    }
            } else {
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
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: mediaBoxSize, height: mediaBoxSize)
        .frame(maxWidth: .infinity)
    }

    // Actions

    private func saveAndDismiss() {
        let imageData = selectedUIImage?.jpegData(compressionQuality: 0.8)
        let win = Win(
            title: winTitle.isEmpty ? "New Win" : winTitle,
            imageData: imageData,
            logTypeIcon: Constants.Icons.oneTime,
            icon1: Constants.Icons.indoor,
            icon2: Constants.Icons.tools,
            icon3: "7D",
            collectionName: selectedCollection
        )
        modelContext.insert(win)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Preview

#Preview("QuickLogView") {
    QuickLogView()
}
