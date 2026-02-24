//
//  AddNewExperimentViewModel.swift
//  SSC_Lab
//
//  Form state and save/update logic for Add New / Edit Experiment. 
//

import Foundation
import SwiftData
import os

@Observable
final class AddNewExperimentViewModel {
    var title: String = ""
    var icon: String = "star.fill"
    var referenceURL: String = ""
    var labNotes: String = ""
    var environment: EnvironmentOption = .indoor
    var tools: ToolsOption = .required
    var timeframe: TimeframeOption = .oneD
    var logType: LogTypeOption = .oneTime

    private(set) var experimentToEdit: Experiment?

    var isEditing: Bool { experimentToEdit != nil }

    var isTitleEmpty: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// If adding: true when any field is non-empty. If editing: true only when form actually differs from experimentToEdit (compare directly to original).
    var hasChanges: Bool {
        guard let exp = experimentToEdit else {
            return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || icon != "star.fill"
                || !referenceURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || !labNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return title != exp.title
            || icon != exp.icon
            || referenceURL != exp.referenceURL
            || labNotes != exp.labNotes
            || environment.rawValue != exp.environment
            || tools.rawValue != exp.tools
            || timeframe.rawValue != exp.timeframe
            || logType.rawValue != (exp.logType ?? "oneTime")
    }

    init(experimentToEdit: Experiment? = nil) {
        self.experimentToEdit = experimentToEdit
        loadFrom(experimentToEdit)
    }

    /// Populate form from an experiment (e.g. when opening for edit).
    func loadFrom(_ experiment: Experiment?) {
        guard let exp = experiment else { return }
        title = exp.title
        icon = exp.icon
        referenceURL = exp.referenceURL
        labNotes = exp.labNotes
        environment = EnvironmentOption(rawValue: exp.environment) ?? .indoor
        tools = ToolsOption(rawValue: exp.tools) ?? .required
        timeframe = TimeframeOption(rawValue: exp.timeframe) ?? .oneD
        if let logTypeValue = exp.logType {
            logType = LogTypeOption(rawValue: logTypeValue) ?? .oneTime
        } else {
            logType = .oneTime
        }
    }

    /// Creates or updates the experiment in the context. Returns true on success; caller should show toast and dismiss. Returns false on save failure; caller should show error toast.
    func save(context: ModelContext) -> Bool {
        guard !isTitleEmpty else { return false }
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if let existing = experimentToEdit {
            existing.title = trimmedTitle
            existing.icon = icon
            existing.referenceURL = referenceURL
            existing.labNotes = labNotes
            existing.environment = environment.rawValue
            existing.tools = tools.rawValue
            existing.timeframe = timeframe.rawValue
            existing.logType = nil // AddNewExperimentView doesn't show logType, so always nil
        } else {
            let experiment = Experiment(
                title: trimmedTitle,
                icon: icon,
                environment: environment.rawValue,
                tools: tools.rawValue,
                timeframe: timeframe.rawValue,
                logType: nil, // AddNewExperimentView doesn't show logType, so always nil
                referenceURL: referenceURL,
                labNotes: labNotes
            )
            context.insert(experiment)
        }
        do {
            try context.save()
            return true
        } catch {
            Logger().error("SwiftData save failed: \(String(describing: error))")
            return false
        }
    }
}
