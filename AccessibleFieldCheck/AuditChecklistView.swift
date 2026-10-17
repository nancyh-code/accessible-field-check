//
//  AuditChecklistView.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 15-10-26.
//

import SwiftUI

struct AuditChecklistView: View {
    let auditID: UUID

    var body: some View {
        ScrollView {
            Text(String(localized: "audit.checklist.shell"))
                .font(.body)
                .foregroundStyle(AFCTokens.Color.secondaryText)
                .multilineTextAlignment(.center)
                .padding(AFCTokens.Spacing.large)
                .frame(maxWidth: .infinity)
        }
        .background(AFCTokens.Color.background)
        .accessibilityIdentifier(AFCAccessibilityID.checklistScreen)
        .navigationTitle(String(localized: "audit.checklist.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AuditChecklistView(auditID: UUID())
    }
}
