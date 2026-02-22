//
//  QuickLogViewModel.swift
//  SSC_Lab
//
//  Form state, validation, and save logic for QuickLogView (log or edit a Win).
//

import Foundation
import SwiftData
import UIKit
import os

/// Result of attempting to save in QuickLogView.
enum QuickLogSaveResult {
    case savedAndDismiss
    case savedSwitchToWinsAndDismiss
    case saveFailed
}

@Observable
final class QuickLogViewModel {
    // Form state
    var winTitle: String = ""
    var selectedIcon: String = "star.fill"
    var selectedCollection: WinCollection?
    var quickNote: String = ""
    var selectedUIImage: UIImage?
    var environment: EnvironmentOption = .indoor
    var tools: ToolsOption = .required
    var timeframe: TimeframeOption = .oneD
    var logType: LogTypeOption = .oneTime

    // New collection popup
    var showNewCollectionPopUp: Bool = false
    var newCollectionName: String = ""

    var hasChanges: Bool {
        !winTitle.isEmpty || !quickNote.isEmpty || selectedUIImage != nil
    }

    /// Prefill form from experiment (Log Win from Lab), win (Edit), or initial collection.
    func prefill(experiment: Experiment?, win: Win?, initialCollection: WinCollection?) {
        if let exp = experiment {
            winTitle = exp.title
            environment = EnvironmentOption(rawValue: exp.environment) ?? .indoor
            tools = ToolsOption(rawValue: exp.tools) ?? .required
            timeframe = TimeframeOption(rawValue: exp.timeframe) ?? .oneD
            logType = LogTypeOption(rawValue: exp.logType ?? "oneTime") ?? .oneTime
        } else if let w = win {
            winTitle = w.title
            quickNote = w.notes
            selectedUIImage = w.imageData.flatMap { UIImage(data: $0) }
            selectedCollection = w.collection
            environment = (w.icon1 == Constants.Icons.outdoor) ? .outdoor : .indoor
            tools = (w.icon2 == Constants.Icons.toolsNone) ? .none : .required
            timeframe = TimeframeOption(rawValue: w.icon3 ?? "1D") ?? .oneD
            logType = (w.logTypeIcon == Constants.Icons.newInterest) ? .newInterest : .oneTime
        }
        if let initial = initialCollection, selectedCollection == nil {
            selectedCollection = initial
        }
    }

    /// Saves the win (create or update). Returns the outcome so the View can dismiss or show error toast.
    func save(context: ModelContext, winToEdit: Win?, experimentToLog: Experiment?) -> QuickLogSaveResult {
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
                try context.save()
                return .savedAndDismiss
            } catch {
                Logger().error("SwiftData save failed: \(String(describing: error))")
                return .saveFailed
            }
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
            context.insert(win)
            win.collection?.lastModified = Date()
            if let experiment = experimentToLog {
                experiment.isActive = false
                experiment.isCompleted = true
            }
            do {
                try context.save()
                return .savedSwitchToWinsAndDismiss
            } catch {
                Logger().error("SwiftData save failed: \(String(describing: error))")
                return .saveFailed
            }
        }
    }

    /// Creates a new collection with the current newCollectionName, selects it, and clears the popup. Returns true if created; false if validation failed or save failed.
    func createNewCollectionAndSelect(context: ModelContext, collections: [WinCollection]) -> Bool {
        let name = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !collections.isDuplicateOrReservedCollectionName(name) else { return false }
        let collection = WinCollection(name: name)
        context.insert(collection)
        do {
            try context.save()
        } catch {
            Logger().error("SwiftData save failed: \(String(describing: error))")
            return false
        }
        selectedCollection = collection
        showNewCollectionPopUp = false
        newCollectionName = ""
        return true
    }
}
