//
//  WinCollection.swift
//  SSC_Lab
//
//  SwiftData model for grouping wins into named collections (e.g. "Pottery", "Hiking").
//  Wins with no collection appear under "Uncategorized".
//

import Foundation
import SwiftData

@Model
final class WinCollection {
    var name: String
    var createdAt: Date

    @Relationship(inverse: \Win.collection)
    var wins: [Win] = []

    init(name: String, createdAt: Date = .now) {
        self.name = name
        self.createdAt = createdAt
    }
}
