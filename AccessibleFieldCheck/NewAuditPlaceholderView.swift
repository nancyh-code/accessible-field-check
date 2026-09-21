//
//  NewAuditPlaceholderView.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 21-09-26.
//

import SwiftUI

struct NewAuditPlaceholderView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: AFCTokens.Spacing.medium) {
                Text("Marcador de posición")
                    .font(.body)
                    .foregroundStyle(AFCTokens.Color.secondaryText)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: AFCTokens.Spacing.small) {
                    AFCStatusBadge(status: .pass)
                    AFCStatusBadge(status: .needsAttention)
                    AFCStatusBadge(status: .notApplicable)
                }
            }
            .padding(AFCTokens.Spacing.large)
            .frame(maxWidth: .infinity)
        }
        .background(AFCTokens.Color.background)
        .navigationTitle("Nueva auditoría")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NewAuditPlaceholderView()
    }
}
