//
//  AuditSummaryView.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 15-10-26.
//

import SwiftUI

struct AuditSummaryView: View {
    let auditID: UUID

    var body: some View {
        ScrollView {
            Text(String(localized: "audit.summary.shell"))
                .font(.body)
                .foregroundStyle(AFCTokens.Color.secondaryText)
                .multilineTextAlignment(.center)
                .padding(AFCTokens.Spacing.large)
                .frame(maxWidth: .infinity)
        }
        .background(AFCTokens.Color.background)
        .accessibilityIdentifier(AFCAccessibilityID.summaryScreen)
        .navigationTitle(String(localized: "audit.summary.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AuditSummaryView(auditID: UUID())
    }
}
