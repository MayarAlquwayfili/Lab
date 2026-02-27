import SwiftUI
import SwiftData
import os

private final class DatabaseLoader: ObservableObject {
    let container: ModelContainer?
    let loadError: Error?

    init() {
        let fileManager = FileManager.default
        if let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            if !fileManager.fileExists(atPath: appSupportURL.path) {
                try? fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
            }
        }

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
                Group {
                    if database.loadError != nil {
                        DatabaseErrorView()
                    } else if let container = database.container {
                        MainTabView()
                            .modelContainer(container)
                            .onAppear {
                                Task {
                                    try? await Task.sleep(for: .seconds(1.0))
                                    SampleData.insertSampleData(context: container.mainContext)
                                }
                            }
                    }
                }
                .preferredColorScheme(.light) 
            }
        }
    }
