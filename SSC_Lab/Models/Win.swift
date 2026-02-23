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
    var icon1: String?
    var icon2: String?
    var icon3: String?
    /// Collection name (e.g. from Quick Log); shown as a tag on the card.
    var collectionName: String?
    /// Optional SwiftData relationship to a WinCollection. If nil, win appears in "Uncategorized".
    var collection: WinCollection?
    /// User notes for the win (bound in detail view).
    var notes: String = ""
    /// When set, links this win to an experiment for repeat count and "Do it again". Preserved even if user edits the title.
    var activityID: UUID?
    /// SF Symbol for the win (experiment icon when created from Lab; user choice when editing). Used for the card badge.
    var icon: String? = nil

    /// Relative date string for UI
    var relativeDateString: String { date.relativeString }

    init(
        title: String,
        imageData: Data? = nil,
        logTypeIcon: String,
        date: Date = .now,
        icon1: String? = nil,
        icon2: String? = nil,
        icon3: String? = nil,
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
        self.icon1 = icon1
        self.icon2 = icon2
        self.icon3 = icon3
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
            icon1: win.icon1,
            icon2: win.icon2,
            icon3: win.icon3,
            collectionName: win.collectionName,
            collection: win.collection,
            notes: win.notes,
            activityID: win.activityID,
            icon: win.icon
        )
    }
}

// Relative date string for Win UI
extension Date {
    var relativeString: String {
        let cal = Calendar.current
        if cal.isDateInToday(self) { return "Today" }
        if cal.isDateInYesterday(self) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
}
