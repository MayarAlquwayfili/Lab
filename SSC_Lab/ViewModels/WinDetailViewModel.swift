//
//  WinDetailViewModel.swift
//  SSC_Lab
//
//  Actions for WinDetailView: delete win, move to collection, create new collection and move, "Do it again".
//

import Foundation
import SwiftData
import os
import UIKit

/// Outcome of deleting a win from the detail carousel.
enum WinDeleteOutcome {
    case dismiss
    case stay(newCarouselIndex: Int)
}

@Observable
final class WinDetailViewModel {
    private let labViewModel = LabViewModel()

    /// Deletes the win, saves, and returns the outcome plus an undo closure.
    @MainActor
    func deleteWin(
        displayedWin: Win,
        boundWinId: PersistentIdentifier,
        winsForCarouselCount: Int,
        currentCarouselIndex: Int,
        context: ModelContext
    ) -> (outcome: WinDeleteOutcome?, undo: (() -> Void)?) {
        
        let copy = Win.copy(from: displayedWin)
        let wasBoundWin = displayedWin.id == boundWinId
        let countBefore = winsForCarouselCount

        /// Dismiss keyboard to prevent gesture conflicts during deletion
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        /// Manually clear relationships to ensure complete deletion in SwiftData
        if let coll = displayedWin.collection {
            coll.wins.removeAll(where: { $0.id == displayedWin.id })
        }
        displayedWin.collection = nil
            
        context.delete(displayedWin)
            
        do {
            context.processPendingChanges()
            try context.save()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            Logger().error("Failed to delete win: \(String(describing: error))")
            context.insert(copy)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return (nil, nil)
        }

        let remainingCount = countBefore - 1
        let outcome: WinDeleteOutcome = (remainingCount <= 0 || wasBoundWin)
            ? .dismiss
            : .stay(newCarouselIndex: max(0, min(currentCarouselIndex, remainingCount - 1)))

        let undo: () -> Void = {
            context.insert(copy)
            try? context.save()
        }
        
        return (outcome, undo)
    }
    
    /// Updates the displayed win's collection and saves. Returns false if save failed.
    func moveToCollection(displayedWin: Win, collection: WinCollection?, context: ModelContext) -> Bool {
        if displayedWin.collection?.id == collection?.id {
            return true
        }
        displayedWin.collection = collection
        displayedWin.collectionName = collection?.name
        collection?.lastModified = Date()
        do {
            try context.save()
            return true
        } catch {
            Logger().error("SwiftData save failed: \(String(describing: error))")
            return false
        }
    }

    /// Creates a new collection, assigns the displayed win to it, and saves.
    func createNewCollectionAndMove(
        displayedWin: Win,
        name: String,
        collections: [WinCollection],
        context: ModelContext
    ) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !collections.isDuplicateOrReservedCollectionName(trimmed) else { return nil }
        let collection = WinCollection(name: trimmed)
        context.insert(collection)
        displayedWin.collection = collection
        displayedWin.collectionName = collection.name
        collection.lastModified = Date()
        do {
            try context.save()
            return trimmed
        } catch {
            Logger().error("SwiftData save failed: \(String(describing: error))")
            return nil
        }
    }

    /// "Do it again": find or create experiment for the win, set active, save, then call switchToHome.
    func openDoItAgain(win: Win, experiments: [Experiment], context: ModelContext, switchToHome: () -> Void) {
        labViewModel.openDoItAgain(win: win, experiments: experiments, context: context, switchToHome: switchToHome)
    }
}
