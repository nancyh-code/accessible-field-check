//
//  AFCStatusBadge.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 21-09-26.
//

import SwiftUI

enum AFCStatus: Hashable, CaseIterable {
    case notReviewed
    case pass
    case needsAttention
    case notApplicable

    init(_ result: AuditResult) {
        switch result {
        case .notReviewed:
            self = .notReviewed
        case .pass:
            self = .pass
        case .needsAttention:
            self = .needsAttention
        case .notApplicable:
            self = .notApplicable
        }
    }

    var result: AuditResult {
        switch self {
        case .notReviewed:
            .notReviewed
        case .pass:
            .pass
        case .needsAttention:
            .needsAttention
        case .notApplicable:
            .notApplicable
        }
    }

    var title: String {
        String(localized: String.LocalizationValue(titleKey))
    }

    var titleKey: String {
        switch self {
        case .notReviewed:
            return "designSystem.status.notReviewed"
        case .pass:
            return "designSystem.status.pass"
        case .needsAttention:
            return "designSystem.status.needsAttention"
        case .notApplicable:
            return "designSystem.status.notApplicable"
        }
    }

    var symbolName: String {
        switch self {
        case .notReviewed:
            return "circle"
        case .pass:
            return "checkmark.circle.fill"
        case .needsAttention:
            return "exclamationmark.triangle.fill"
        case .notApplicable:
            return "minus.circle.fill"
        }
    }

    var color: SwiftUI.Color {
        switch self {
        case .notReviewed:
            return AFCTokens.Color.secondaryText
        case .pass:
            return AFCTokens.Color.success
        case .needsAttention:
            return AFCTokens.Color.warning
        case .notApplicable:
            return AFCTokens.Color.secondaryText
        }
    }
}

struct AFCStatusBadge: View {
    let status: AFCStatus

    var body: some View {
        Label(status.title, systemImage: status.symbolName)
            .font(.subheadline)
            .foregroundStyle(status.color)
            .padding(.horizontal, AFCTokens.Spacing.medium)
            .padding(.vertical, AFCTokens.Spacing.small)
            .background(
                status.color.opacity(0.15),
                in: RoundedRectangle(cornerRadius: AFCTokens.Radius.small, style: .continuous)
            )
            .accessibilityElement(children: .combine)
    }
}

#Preview("All statuses") {
    VStack(alignment: .leading, spacing: AFCTokens.Spacing.medium) {
        ForEach(AFCStatus.allCases, id: \.self) { status in
            AFCStatusBadge(status: status)
        }
    }
    .padding(AFCTokens.Spacing.medium)
}

#Preview("Accessibility extra extra extra large") {
    VStack(alignment: .leading, spacing: AFCTokens.Spacing.medium) {
        ForEach(AFCStatus.allCases, id: \.self) { status in
            AFCStatusBadge(status: status)
        }
    }
    .padding(AFCTokens.Spacing.medium)
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}

#Preview("Dark") {
    VStack(alignment: .leading, spacing: AFCTokens.Spacing.medium) {
        ForEach(AFCStatus.allCases, id: \.self) { status in
            AFCStatusBadge(status: status)
        }
    }
    .padding(AFCTokens.Spacing.medium)
    .preferredColorScheme(.dark)
}
