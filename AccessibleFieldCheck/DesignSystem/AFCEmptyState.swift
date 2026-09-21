//
//  AFCEmptyState.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 21-09-26.
//

import SwiftUI

struct AFCEmptyState<Action: View>: View {
    let title: String
    var message: String?
    @ViewBuilder var action: () -> Action

    var body: some View {
        VStack(spacing: AFCTokens.Spacing.medium) {
            Text(title)
                .font(.title2)
                .foregroundStyle(AFCTokens.Color.primaryText)
                .multilineTextAlignment(.center)

            if let message {
                Text(message)
                    .font(.body)
                    .foregroundStyle(AFCTokens.Color.secondaryText)
                    .multilineTextAlignment(.center)
            }

            action()
        }
        .frame(maxWidth: 480)
        .padding(AFCTokens.Spacing.large)
        .frame(maxWidth: .infinity)
    }
}

#Preview("Audits empty") {
    AFCEmptyState(title: "No hay auditorías todavía") {
        AFCPrimaryButton(title: "Nueva auditoría", action: {})
    }
}

#Preview("Accessibility extra extra extra large") {
    AFCEmptyState(title: "No hay auditorías todavía") {
        AFCPrimaryButton(title: "Nueva auditoría", action: {})
    }
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
