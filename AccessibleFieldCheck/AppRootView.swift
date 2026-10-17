//
//  AppRootView.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 21-09-26.
//

import SwiftData
import SwiftUI

enum AppDestination: Hashable {
    case newAudit
    case checklist(UUID)
    case summary(UUID)
}

struct AppRootView: View {
    @State private var path: [AppDestination] = []

    var body: some View {
        NavigationStack(path: $path) {
            AuditsView(path: $path)
                .navigationDestination(for: AppDestination.self) { destination in
                    switch destination {
                    case .newAudit:
                        NewAuditView(path: $path)
                    case .checklist(let auditID):
                        AuditChecklistView(auditID: auditID)
                    case .summary(let auditID):
                        AuditSummaryView(auditID: auditID)
                    }
                }
        }
    }
}

#Preview {
    AppRootView()
        .modelContainer(for: [Audit.self, AuditItem.self], inMemory: true)
}
