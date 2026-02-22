//
//  WinCollection.swift
//  SSC_Lab
//
//  SwiftData model for grouping wins into named collections
//

import Foundation
import SwiftData

@Model
final class WinCollection {
    var name: String
    var createdAt: Date
    /// Updated when a win is added to this collection or a win in this collection is edited.
    var lastModified: Date

    @Relationship(inverse: \Win.collection)
    var wins: [Win] = []

    init(name: String, createdAt: Date = .now, lastModified: Date? = nil) {
        self.name = name
        self.createdAt = createdAt
        self.lastModified = lastModified ?? createdAt
    }
}
