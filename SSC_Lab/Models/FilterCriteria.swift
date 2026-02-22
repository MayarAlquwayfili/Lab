//
//  FilterCriteria.swift
//  SSC_Lab
//
//  Domain logic for filtering experiments and wins by badge categories (Environment, Tools, Time, Log).
//

import Foundation

struct FilterCriteria {
    var selectedBadges: Set<BadgeType> = []

    /// Categories used for AND logic: Environment, Tools, Time, Log.
    private static func category(of badge: BadgeType) -> Int {
        switch badge {
        case .indoor, .outdoor: return 0
        case .tools, .noTools: return 1
        case .timeframe: return 2
        case .oneTime, .newInterest: return 3
        case .link: return -1
        }
    }

    /// Returns true if criteria is empty (show all), or if the experiment matches at least one selected badge in every active category (AND logic).
    func matches(_ experiment: Experiment) -> Bool {
        guard !selectedBadges.isEmpty else { return true }

        let expEnv = LabViewModel.topBadge(for: experiment.environment)
        let expTools: BadgeType = experiment.tools.lowercased() == "none" ? .noTools : .tools
        let expTime = BadgeType.timeframe(experiment.timeframe)
        var expLog: BadgeType?
        if let log = experiment.logType, log == "newInterest" { expLog = .newInterest }
        else if experiment.logType != nil { expLog = .oneTime }

        let envSelected = selectedBadges.filter { Self.category(of: $0) == 0 }
        let toolsSelected = selectedBadges.filter { Self.category(of: $0) == 1 }
        let timeSelected = selectedBadges.filter { Self.category(of: $0) == 2 }
        let logSelected = selectedBadges.filter { Self.category(of: $0) == 3 }

        if !envSelected.isEmpty && !envSelected.contains(expEnv) { return false }
        if !toolsSelected.isEmpty && !toolsSelected.contains(expTools) { return false }
        if !timeSelected.isEmpty && !timeSelected.contains(expTime) { return false }
        if !logSelected.isEmpty {
            guard let log = expLog, logSelected.contains(log) else { return false }
        }
        return true
    }

    var isEmpty: Bool {
        selectedBadges.isEmpty
    }

    /// Returns true if criteria is empty, or if the win matches at least one selected badge in every active category (AND logic).
    func matches(_ win: Win) -> Bool {
        guard !selectedBadges.isEmpty else { return true }
        let iconNames = [win.icon1, win.icon2, win.icon3, win.logTypeIcon].compactMap { $0 }
        let winBadges = Set(iconNames.compactMap { BadgeType.from(iconName: $0) })
        let envSelected = selectedBadges.filter { Self.category(of: $0) == 0 }
        let toolsSelected = selectedBadges.filter { Self.category(of: $0) == 1 }
        let timeSelected = selectedBadges.filter { Self.category(of: $0) == 2 }
        let logSelected = selectedBadges.filter { Self.category(of: $0) == 3 }
        if !envSelected.isEmpty && envSelected.intersection(winBadges).isEmpty { return false }
        if !toolsSelected.isEmpty && toolsSelected.intersection(winBadges).isEmpty { return false }
        if !timeSelected.isEmpty && timeSelected.intersection(winBadges).isEmpty { return false }
        if !logSelected.isEmpty && logSelected.intersection(winBadges).isEmpty { return false }
        return true
    }
}
