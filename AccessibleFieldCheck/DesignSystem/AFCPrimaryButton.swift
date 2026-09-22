//
//  AFCPrimaryButton.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 21-09-26.
//

import SwiftUI

struct AFCPrimaryButton: View {
    let title: String
    var accessibilityIdentifier: String? = nil
    let action: () -> Void

    var body: some View {
        button
            .buttonStyle(.borderedProminent)
            .tint(AFCTokens.Color.accent)
            .modifier(OptionalAccessibilityIdentifier(identifier: accessibilityIdentifier))
    }

    private var button: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.horizontal, AFCTokens.Spacing.medium)
                .padding(.vertical, AFCTokens.Spacing.small)
        }
    }
}

private struct OptionalAccessibilityIdentifier: ViewModifier {
    let identifier: String?

    func body(content: Content) -> some View {
        if let identifier {
            content.accessibilityIdentifier(identifier)
        } else {
            content
        }
    }
}

#Preview("Default") {
    AFCPrimaryButton(title: String(localized: "audit.empty.action"), action: {})
        .padding(AFCTokens.Spacing.medium)
}

#Preview("Accessibility extra extra extra large") {
    AFCPrimaryButton(title: String(localized: "audit.empty.action"), action: {})
        .padding(AFCTokens.Spacing.medium)
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}

#Preview("Dark") {
    AFCPrimaryButton(title: String(localized: "audit.empty.action"), action: {})
        .padding(AFCTokens.Spacing.medium)
        .preferredColorScheme(.dark)
}
