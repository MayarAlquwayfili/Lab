//
//  SSC_LabApp.swift
//  SSC_Lab
//
//  Created by yumii on 09/02/2026.
//
//  Data: Username/onboarding live in UserDefaults (@AppStorage). Wins, Experiments,
//  and Collections live in SwiftData (persistent store). If SwiftData fails to load
//  or migrates badly, only the DB is affected; UserDefaults is separate, so the
//  username can persist while Wins/Collections disappear.
//

import SwiftUI
import SwiftData
import os

/// Holds the result of loading the SwiftData container. Used so we can show DatabaseErrorView instead of crashing.
private final class DatabaseLoader: ObservableObject {
    let container: ModelContainer?
    let loadError: Error?

    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            self.container = try ModelContainer(
                for: Schema(versionedSchema: AppSchemaV1.self),
                migrationPlan: AppMigrationPlan.self,
                configurations: [config]
            )
            self.loadError = nil
        } catch {
            Logger().error("SwiftData ModelContainer failed: \(String(describing: error))")
            self.container = nil
            self.loadError = error
        }
    }
}

@main
struct SSC_LabApp: App {
    @StateObject private var database = DatabaseLoader()

    init() {
        FontRegistration.registerCustomFonts()
    }

    var body: some Scene {
        WindowGroup {
            if database.loadError != nil {
                DatabaseErrorView()
            } else if let container = database.container {
                MainTabView()
                    .modelContainer(container)
            }
        }
    }
}
