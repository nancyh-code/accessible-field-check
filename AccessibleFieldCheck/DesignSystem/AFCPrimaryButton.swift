//
//  AFCPrimaryButton.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 21-09-26.
//

import SwiftUI

struct AFCPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.horizontal, AFCTokens.Spacing.medium)
                .padding(.vertical, AFCTokens.Spacing.small)
        }
        .buttonStyle(.borderedProminent)
        .tint(AFCTokens.Color.accent)
    }
}

#Preview("Default") {
    AFCPrimaryButton(title: "Nueva auditoría", action: {})
        .padding(AFCTokens.Spacing.medium)
}

#Preview("Accessibility extra extra extra large") {
    AFCPrimaryButton(title: "Nueva auditoría", action: {})
        .padding(AFCTokens.Spacing.medium)
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}

#Preview("Dark") {
    AFCPrimaryButton(title: "Nueva auditoría", action: {})
        .padding(AFCTokens.Spacing.medium)
        .preferredColorScheme(.dark)
}
