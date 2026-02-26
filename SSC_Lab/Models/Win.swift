//
//  Win.swift
//  SSC_Lab
//
//  SwiftData model for a logged win.  
//

import Foundation
import SwiftData

@Model
final class Win {
    var title: String
    var imageData: Data?
    var createdAt: Date = Date()
    var logTypeIcon: String
    var date: Date = Date()
    var environment: String?
    var tools: String?
    var timeframe: String?
    var collectionName: String?
    var collection: WinCollection?
    var notes: String = ""
    /// When set, links this win to an experiment for repeat count and "Do it again". Preserved even if user edits the title.
    var activityID: UUID?
    var icon: String? = nil

    /// Relative date string for UI
    var relativeDateString: String { date.relativeString }

    init(
        title: String,
        imageData: Data? = nil,
        logTypeIcon: String,
        date: Date = .now,
        environment: String? = nil,
        tools: String? = nil,
        timeframe: String? = nil,
        collectionName: String? = nil,
        collection: WinCollection? = nil,
        notes: String = "",
        activityID: UUID? = nil,
        icon: String? = nil
    ) {
        self.title = title
        self.imageData = imageData
        self.logTypeIcon = logTypeIcon
        self.date = date
        self.environment = environment
        self.tools = tools
        self.timeframe = timeframe
        self.collectionName = collectionName
        self.collection = collection
        self.notes = notes
        self.activityID = activityID
        self.icon = icon
    }

    /// Creates a new Win with the same property values (for undo-after-delete). Caller must insert into context.
    static func copy(from win: Win) -> Win {
        Win(
            title: win.title,
            imageData: win.imageData,
            logTypeIcon: win.logTypeIcon,
            date: win.date,
            environment: win.environment,
            tools: win.tools,
            timeframe: win.timeframe,
            collectionName: win.collectionName,
            collection: win.collection,
            notes: win.notes,
            activityID: win.activityID,
            icon: win.icon
        )
    }
}

/// Relative date string for Win UI
extension Date {
    var relativeString: String {
        let cal = Calendar.current
        if cal.isDateInToday(self) { return "Today" }
        if cal.isDateInYesterday(self) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }

    /// Short relative time for "Last Win" footer 
    var timeAgoString: String {
        let sec = Int(-timeIntervalSinceNow)
        if sec < 60 { return "Just now" }
        if sec < 3600 { return "\(sec / 60)m Ago" }
        if sec < 86400 { return "\(sec / 3600)h Ago" }
        if sec < 604800 { return "\(sec / 86400)d Ago" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
}
