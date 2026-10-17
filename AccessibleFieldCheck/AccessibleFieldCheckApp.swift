//
//  AccessibleFieldCheckApp.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 21-09-26.
//

import SwiftData
import SwiftUI

@main
struct AccessibleFieldCheckApp: App {
    private let modelContainer: ModelContainer

    init() {
        modelContainer = Self.makeModelContainer()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(modelContainer)
    }

    private static func makeModelContainer() -> ModelContainer {
        let usesEmptyStore = ProcessInfo.processInfo.arguments.contains("-ui-testing-empty-store")
        do {
            if usesEmptyStore {
                let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
                return try ModelContainer(
                    for: Audit.self,
                    AuditItem.self,
                    configurations: configuration
                )
            }

            return try ModelContainer(for: Audit.self, AuditItem.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
