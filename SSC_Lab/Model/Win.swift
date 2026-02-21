//
//  Win.swift
//  SSC_Lab
//
//  SwiftData model for a logged win. Conforms to Identifiable via @Model.
//

import Foundation
import SwiftData

@Model
final class Win {
    var title: String
    var imageData: Data?
    var createdAt: Date = Date()
    var logTypeIcon: String   // 4th icon on WinCard (e.g. oneTime, newInterest)
    var date: Date = Date()
    /// Optional icon names (SF Symbol or asset) for the first 3 badges on the card.
    var icon1: String?
    var icon2: String?
    var icon3: String?
    /// Collection name (e.g. from Quick Log); shown as a tag on the card.
    var collectionName: String?
    /// Optional SwiftData relationship to a WinCollection. If nil, win appears in "Uncategorized".
    var collection: WinCollection?
    /// User notes for the win (bound in detail view).
    var notes: String = ""

    /// Relative date string for UI: "Today", "Yesterday", or "Feb 21".
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
        notes: String = ""
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
    }
}

// MARK: - Relative date string for Win UI
extension Date {
    /// "Today", "Yesterday", or "Feb 21" style.
    var relativeString: String {
        let cal = Calendar.current
        if cal.isDateInToday(self) { return "Today" }
        if cal.isDateInYesterday(self) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
}
