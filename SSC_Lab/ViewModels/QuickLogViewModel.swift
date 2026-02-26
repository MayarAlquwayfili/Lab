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
    /// Form state
    var winTitle: String = ""
    var selectedIcon: String = "star.fill"
    var selectedCollection: WinCollection?
    var quickNote: String = ""
    var selectedUIImage: UIImage?
    var environment: EnvironmentOption = .indoor
    var tools: ToolsOption = .required
    var timeframe: TimeframeOption = .oneD
    var logType: LogTypeOption = .oneTime

    /// New collection popup
    var showNewCollectionPopUp: Bool = false
    var newCollectionName: String = ""

    /// Set to true only when the user picks a new image from gallery/camera.
    private(set) var isImageNew: Bool = false

    /// Call when the user has picked a new image from camera or photo library.
    func markImageAsNew() {
        isImageNew = true
    }

    /// True only when user actually modified something. Compare current state directly to the original win when editing; when adding, true if any field is non-empty.
    func hasChanges(winToEdit: Win?) -> Bool {
        guard let win = winToEdit else {
            return !winTitle.isEmpty || !quickNote.isEmpty || selectedUIImage != nil
        }
        let imageChanged = isImageNew || (win.imageData != nil && selectedUIImage == nil)
        let collectionChanged = (selectedCollection?.id != win.collection?.id)
        let iconSame = (selectedIcon == (win.icon ?? "star.fill"))
        let envSame = (environment == ((win.environment == Constants.Icons.outdoor) ? .outdoor : .indoor))
        let toolsSame = (tools == ((win.tools == Constants.Icons.toolsNone) ? .none : .required))
        let timeframeSame = (timeframe == (TimeframeOption(rawValue: win.timeframe ?? "1D") ?? .oneD))
        let logTypeSame = (logType == ((win.logTypeIcon == Constants.Icons.newInterest) ? .newInterest : .oneTime))
        return winTitle != win.title
            || quickNote != win.notes
            || imageChanged
            || collectionChanged
            || !iconSame
            || !envSame
            || !toolsSame
            || !timeframeSame
            || !logTypeSame
    }

    /// Prefill form from experiment (Log Win from Lab), win (Edit), or initial collection.
    func prefill(experiment: Experiment?, win: Win?, initialCollection: WinCollection?) {
        if let exp = experiment {
            winTitle = exp.title
            selectedIcon = exp.icon
            environment = EnvironmentOption(rawValue: exp.environment) ?? .indoor
            tools = ToolsOption(rawValue: exp.tools) ?? .required
            timeframe = TimeframeOption(rawValue: exp.timeframe) ?? .oneD
            logType = LogTypeOption(rawValue: exp.logType ?? "oneTime") ?? .oneTime
        } else if let w = win {
            isImageNew = false
            winTitle = w.title
            selectedIcon = w.icon ?? "star.fill"
            quickNote = w.notes
            selectedUIImage = w.imageData.flatMap { UIImage(data: $0) }
            selectedCollection = w.collection
            environment = (w.environment == Constants.Icons.outdoor) ? .outdoor : .indoor
            tools = (w.tools == Constants.Icons.toolsNone) ? .none : .required
            timeframe = TimeframeOption(rawValue: w.timeframe ?? "1D") ?? .oneD
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
            win.environment = icon1
            win.tools = icon2
            win.timeframe = icon3
            win.logTypeIcon = logTypeIcon
            win.icon = selectedIcon
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
                environment: icon1,
                tools: icon2,
                timeframe: icon3,
                collectionName: selectedCollection?.name,
                collection: selectedCollection,
                notes: quickNote,
                activityID: experimentToLog?.activityID,
                icon: selectedIcon
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
