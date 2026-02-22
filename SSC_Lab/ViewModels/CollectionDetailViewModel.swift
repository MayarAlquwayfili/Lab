//
//  CollectionDetailViewModel.swift
//  SSC_Lab
//
//  Actions for CollectionDetailView: delete win (with undo), "Do it again" (via LabViewModel).
//

import Foundation
import SwiftData
import os

@Observable
final class CollectionDetailViewModel {
    private let labViewModel = LabViewModel()

    /// Deletes the win and saves. On success returns an undo closure; on failure re-inserts the win and returns nil.
    func deleteWin(win: Win, context: ModelContext) -> (() -> Void)? {
        let copy = Win.copy(from: win)
        context.delete(win)
        do {
            try context.save()
        } catch {
            Logger().error("SwiftData save failed: \(String(describing: error))")
            context.insert(copy)
            return nil
        }
        return {
            context.insert(copy)
            try? context.save()
        }
    }

    /// "Do it again": find or create experiment for the win, set active, save, then call switchToHome.
    func openDoItAgain(win: Win, experiments: [Experiment], context: ModelContext, switchToHome: () -> Void) {
        labViewModel.openDoItAgain(win: win, experiments: experiments, context: context, switchToHome: switchToHome)
    }
}
