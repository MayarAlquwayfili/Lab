//
//  Experiment.swift
//  SSC_Lab
//
//  SwiftData model for a lab experiment. Conforms to Identifiable via @Model.
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
    var isActive: Bool        // Currently active experiment (only one at a time)
    var createdAt: Date       // For sorting (newest first)

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
        createdAt: Date = .now
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
        self.createdAt = createdAt
    }
}
