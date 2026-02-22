//
//  AppSchema.swift
//  SSC_Lab
//
//  Versioned schema and migration plan so SwiftData migrates on model changes
//

import Foundation
import SwiftData

enum AppSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] {
        [Experiment.self, Win.self, WinCollection.self]
    }
}


enum AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [AppSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
