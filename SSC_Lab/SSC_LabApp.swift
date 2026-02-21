//
//  SSC_LabApp.swift
//  SSC_Lab
//
//  Created by yumii on 09/02/2026.
//

import SwiftUI
import SwiftData

@main
struct SSC_LabApp: App {
    init() {
        FontRegistration.registerCustomFonts()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [Experiment.self, Win.self, WinCollection.self])
    }
}
