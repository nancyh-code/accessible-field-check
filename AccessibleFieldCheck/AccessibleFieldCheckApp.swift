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
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [Audit.self, AuditItem.self])
    }
}
