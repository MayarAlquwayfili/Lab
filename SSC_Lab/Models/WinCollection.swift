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

/// Collection name validation (shared by QuickLogView, WinDetailView, CollectionsGalleryView)

extension Array where Element == WinCollection {
    /// Reserved names that cannot be used for user-created collections (normalized for comparison).
    private static var reservedNormalizedNames: Set<String> {
        ["all", "all wins", "uncategorized"]
    }

    /// Set of existing collection names (lowercased) plus reserved names. Use for duplicate and reserved-name checks.
    var collectionNameSetIncludingReserved: Set<String> {
        var names = Set(map { $0.name.lowercased() })
        names.formUnion(Self.reservedNormalizedNames)
        return names
    }

    /// Returns true if the given name (after trimming and lowercasing) is empty, reserved, or already used by a collection.
    func isDuplicateOrReservedCollectionName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return collectionNameSetIncludingReserved.contains(trimmed.lowercased())
    }
}
