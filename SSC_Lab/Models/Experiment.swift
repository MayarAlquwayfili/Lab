//
//  Experiment.swift
//  SSC_Lab
//
//  SwiftData model for a lab experiment. 
//

import Foundation
import SwiftData

@Model
final class Experiment {
    var title: String
    var icon: String
    var environment: String
    var tools: String
    var timeframe: String
    var logType: String?      
    var referenceURL: String
    var labNotes: String
    var isActive: Bool        /// Currently active experiment (only one at a time)
    var isCompleted: Bool     /// true when a Win was logged from this experiment (graduated; hidden from Lab)
    var activatedAt: Date?    /// When this experiment was last set active (nil when inactive)
    var createdAt: Date       /// For sorting (newest first)
    /// Stable id for linking wins to this experiment (repeat counter, "Do it again"). New experiments get a UUID; existing may be nil.
    var activityID: UUID?

    init(
        title: String,
        icon: String = "star.fill",
        environment: String = "indoor",
        tools: String = "required",
        timeframe: String = "1D",
        logType: String? = nil,
        referenceURL: String = "",
        labNotes: String = "",
        isActive: Bool = false,
        isCompleted: Bool = false,
        activatedAt: Date? = nil,
        createdAt: Date = .now,
        activityID: UUID? = nil
    ) {
        self.title = title
        self.icon = icon
        self.environment = environment
        self.tools = tools
        self.timeframe = timeframe
        self.logType = logType
        self.referenceURL = referenceURL
        self.labNotes = labNotes
        self.isActive = isActive
        self.isCompleted = isCompleted
        self.activatedAt = activatedAt
        self.createdAt = createdAt
        self.activityID = activityID ?? UUID()
    }

    /// Creates a copy of the experiment for undo-after-delete. Caller must insert into context.
    static func copy(from experiment: Experiment) -> Experiment {
        Experiment(
            title: experiment.title,
            icon: experiment.icon,
            environment: experiment.environment,
            tools: experiment.tools,
            timeframe: experiment.timeframe,
            logType: experiment.logType,
            referenceURL: experiment.referenceURL,
            labNotes: experiment.labNotes,
            isActive: experiment.isActive,
            isCompleted: experiment.isCompleted,
            activatedAt: experiment.activatedAt,
            createdAt: experiment.createdAt,
            activityID: experiment.activityID
        )
    }
}
