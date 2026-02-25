//
//  LabViewModel.swift
//  SSC_Lab
//
//  Logic for Lab: delete, randomize, toggle active, and badge derivation for experiments.
//

import Foundation
import SwiftData
import os

@Observable
final class LabViewModel {

    // SwiftData actions

    /// Deletes the experiment immediately and saves. On success returns an undo closure that re-inserts the experiment; on save failure returns nil (caller should show error toast).
    func deleteExperiment(experiment: Experiment, context: ModelContext) -> (() -> Void)? {
        let copy = Experiment.copy(from: experiment)
        context.delete(experiment)
        do {
            try context.save()
        } catch {
            Logger().error("SwiftData save failed: \(String(describing: error))")
            context.insert(experiment)
            return nil
        }
        return {
            context.insert(copy)
            do {
                try context.save()
            } catch {
                Logger().error("SwiftData undo save failed: \(String(describing: error))")
            }
        }
    }

    /// Returns a random experiment from the array, or nil if empty.
    func randomize(from experiments: [Experiment]) -> Experiment? {
        guard !experiments.isEmpty else { return nil }
        return experiments.randomElement()
    }

    /// Filter experiments by search text and filter criteria.
    func filteredExperiments(_ experiments: [Experiment], searchText: String, filterCriteria: FilterCriteria) -> [Experiment] {
        var result = experiments
        if !filterCriteria.isEmpty {
            result = result.filter { filterCriteria.matches($0) }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }

    /// Toggles active state: if currently active, deactivates; otherwise deactivates all others and sets this one active.
    /// Calls `onActivated(previousActive)` only when an experiment is actually activated; pass the experiment that was active before the switch, or nil if none.
    /// Saves immediately so state (and any Undo re-toggle) is persisted.
    func toggleActive(experiment: Experiment, allExperiments: [Experiment], context: ModelContext, onActivated: ((Experiment?) -> Void)? = nil) {
        if experiment.isActive {
            experiment.isActive = false
            experiment.activatedAt = nil
        } else {
            let previousActive = allExperiments.first { $0.isActive }
            for exp in allExperiments where exp.id != experiment.id {
                exp.isActive = false
                exp.activatedAt = nil
            }
            experiment.isActive = true
            experiment.activatedAt = Date()
            onActivated?(previousActive)
        }
        try? context.save() // Force write to disk immediately (including after Undo restore)
    }

    // Badge derivation (single source of truth for Experiment → BadgeType)

    /// Maps environment string to top badge type.
    static func topBadge(for environment: String) -> BadgeType {
        environment.lowercased() == "outdoor" ? .outdoor : .indoor
    }

    /// Maps experiment to ordered bottom badge types  
    static func bottomBadges(for experiment: Experiment) -> [BadgeType] {
        var badges: [BadgeType] = []
        badges.append(topBadge(for: experiment.environment))
        badges.append(experiment.tools.lowercased() == "none" ? .noTools : .tools)
        badges.append(.timeframe(experiment.timeframe))
        if let log = experiment.logType, log == "newInterest" {
            badges.append(.newInterest)
        } else if experiment.logType != nil {
            badges.append(.oneTime)
        }
        return badges
    }

    /// True when the experiment has a non-empty reference URL.
    static func hasReferenceURL(_ experiment: Experiment) -> Bool {
        !experiment.referenceURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Do it again (shared by WinDetailView and CollectionDetailView)

    /// Creates a temporary experiment from a Win so QuickLogView can prefill (e.g. when original experiment was removed from Lab).
    static func temporaryExperiment(from win: Win) -> Experiment {
        let env = (win.icon1 == Constants.Icons.outdoor) ? "outdoor" : "indoor"
        let toolsStr = (win.icon2 == Constants.Icons.toolsNone) ? "none" : "required"
        let timeframeStr = win.icon3 ?? "1D"
        let logTypeStr: String? = (win.logTypeIcon == Constants.Icons.newInterest) ? "newInterest" : "oneTime"
        return Experiment(
            title: win.title,
            icon: "star.fill",
            environment: env,
            tools: toolsStr,
            timeframe: timeframeStr,
            logType: logTypeStr,
            referenceURL: "",
            labNotes: "",
            isActive: false,
            isCompleted: false,
            createdAt: .now,
            activityID: win.activityID ?? UUID()
        )
    }

    /// Finds or creates an experiment for the win, sets it active, saves, then calls switchToHome (e.g. switch tab to Home so QuickLogView can be presented).
    func openDoItAgain(win: Win, experiments: [Experiment], context: ModelContext, switchToHome: () -> Void) {
        let exp: Experiment? = win.activityID.flatMap { id in experiments.first(where: { $0.activityID == id }) }
            ?? experiments.first(where: { $0.title == win.title })
        let target: Experiment
        if let existing = exp {
            target = existing
        } else {
            let temp = Self.temporaryExperiment(from: win)
            context.insert(temp)
            target = temp
        }
        for e in experiments where e.id != target.id {
            e.isActive = false
            e.activatedAt = nil
        }
        target.isActive = true
        target.activatedAt = Date()
        try? context.save()
        switchToHome()
    }
}
