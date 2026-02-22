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

    func delete(experiment: Experiment, context: ModelContext) {
        context.delete(experiment)
        try? context.save() // Force write to disk immediately
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

    /// Excludes the experiment pending delete from the list (for undo flow).
    func experimentsToShow(from filtered: [Experiment], pendingDelete: Experiment?) -> [Experiment] {
        guard let pending = pendingDelete else { return filtered }
        return filtered.filter { $0.id != pending.id }
    }

    /// Toggles active state: if currently active, deactivates; otherwise deactivates all others and sets this one active.
    /// Calls `onActivated(previousActive)` only when an experiment is actually activated; pass the experiment that was active before the switch, or nil if none.
    /// Saves immediately so state (and any Undo re-toggle) is persisted.
    func toggleActive(experiment: Experiment, allExperiments: [Experiment], context: ModelContext, onActivated: ((Experiment?) -> Void)? = nil) {
        if experiment.isActive {
            experiment.isActive = false
        } else {
            let previousActive = allExperiments.first { $0.isActive }
            for exp in allExperiments where exp.id != experiment.id {
                exp.isActive = false
            }
            experiment.isActive = true
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
        }
        target.isActive = true
        try? context.save()
        switchToHome()
    }
}
