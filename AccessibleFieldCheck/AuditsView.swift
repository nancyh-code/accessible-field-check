//
//  AuditsView.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 21-09-26.
//

import SwiftUI

struct AuditsView: View {
    @Binding var path: [AppDestination]

    var body: some View {
        ScrollView {
            AFCEmptyState(title: String(localized: "audit.empty.title")) {
                AFCPrimaryButton(
                    title: String(localized: "audit.empty.action"),
                    accessibilityIdentifier: AFCAccessibilityID.auditsNewAuditButton
                ) {
                    path.append(.newAudit)
                }
            }
            .accessibilityIdentifier(AFCAccessibilityID.auditsEmptyState)
        }
        .background(AFCTokens.Color.background)
        .accessibilityIdentifier(AFCAccessibilityID.auditsScreen)
        .navigationTitle(String(localized: "navigation.audits.title"))
    }
}

#Preview {
    NavigationStack {
        AuditsView(path: .constant([]))
    }
}
