//
//  AddNewExperimentView.swift
//  SSC_Lab
//
//  Add or edit experiment form.
//

import SwiftUI
import SwiftData

struct AddNewExperimentView: View {
    var experimentToEdit: Experiment?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: AddNewExperimentViewModel
    @State private var showDiscardAlert = false
    @State private var showIconPicker = false

    private let horizontalMargin: CGFloat = Constants.Lab.horizontalMargin

    init(experimentToEdit: Experiment? = nil) {
        self.experimentToEdit = experimentToEdit
        _viewModel = State(initialValue: AddNewExperimentViewModel(experimentToEdit: experimentToEdit))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeader(title: viewModel.isEditing ? Constants.Lab.headerEdit : Constants.Lab.headerAddNew) {
                    Button(action: { if viewModel.hasChanges { showDiscardAlert = true } else { dismiss() } }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.appSecondaryDark)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.appFont.opacity(0.05)))
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                } rightContent: {
                    Button(action: {
                        guard !viewModel.isTitleEmpty else { return }
                        viewModel.save(context: modelContext)
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.appPrimary))
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isTitleEmpty)
                    .opacity(viewModel.isTitleEmpty ? 0.5 : 1)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Section 1: Experiments
                        EmptyView().sectionHeader(title: Constants.Lab.sectionExperiments, topSpacing: 10, horizontalPadding: horizontalMargin)
                        AppExperimentInputCard(title: $viewModel.title, icon: $viewModel.icon, onIconTap: { showIconPicker = true })
                            .padding(.horizontal, horizontalMargin)

                        // Section 2: Setup
                        EmptyView().sectionHeader(title: Constants.Lab.sectionSetup, horizontalPadding: horizontalMargin)
                        ExperimentSetupCard(
                            showLogType: false,
                            environment: $viewModel.environment,
                            tools: $viewModel.tools,
                            timeframe: $viewModel.timeframe,
                            logType: $viewModel.logType
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, horizontalMargin)

                        // Section 3: Reference
                        EmptyView().sectionHeader(title: Constants.Lab.sectionReference, horizontalPadding: horizontalMargin)
                        referenceField
                            .padding(.horizontal, horizontalMargin)

                        AppNoteEditor(text: $viewModel.labNotes, placeholder: Constants.Lab.placeholderNote)
                            .padding(.top, 30)
                            .padding(.horizontal, horizontalMargin)

                        // Footer
                        Spacer()
                            .frame(height: 30)
                        AppButton(title: viewModel.isEditing ? Constants.Lab.buttonSaveChanges : Constants.Lab.buttonAddToLab, style: .primary) {
                            viewModel.save(context: modelContext)
                            dismiss()
                        }
                        .disabled(viewModel.isTitleEmpty)
                        .padding(.horizontal, horizontalMargin)
                    }
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBg.ignoresSafeArea())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg.ignoresSafeArea())
            .navigationBarHidden(true)
            .showPopUp(
                isPresented: $showDiscardAlert,
                title: Constants.Lab.discardAlertTitle,
                message: Constants.Lab.discardAlertMessage,
                primaryButtonTitle: Constants.Lab.discardAlertPrimary,
                secondaryButtonTitle: Constants.Lab.discardAlertSecondary,
                primaryStyle: .destructive,
                showCloseButton: false,
                onPrimary: { dismiss() },
                onSecondary: { showDiscardAlert = false }
            )
        }
    }

 
    private var referenceField: some View {
        TextField(Constants.Lab.placeholderReference, text: $viewModel.referenceURL)
            .font(.appBodySmall)
            .foregroundStyle(Color.appFont)
            .padding(.horizontal, 16)
            .frame(height: 35)
            .background(Capsule().fill(Color.white))
            .overlay(Capsule().stroke(Color.appSecondary, lineWidth: 1))
    }

}

#Preview {
    AddNewExperimentView()
}
