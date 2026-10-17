//
//  AuditsView.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 21-09-26.
//

import SwiftData
import SwiftUI

struct AuditsView: View {
    @Binding var path: [AppDestination]
    @Query(sort: \Audit.updatedAt, order: .reverse) private var audits: [Audit]

    var body: some View {
        Group {
            if audits.isEmpty {
                emptyState
            } else {
                auditList
            }
        }
        .background(AFCTokens.Color.background)
        .accessibilityIdentifier(AFCAccessibilityID.auditsScreen)
        .navigationTitle(String(localized: "navigation.audits.title"))
        .toolbar {
            if !audits.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        path.append(.newAudit)
                    } label: {
                        Label(String(localized: "audit.empty.action"), systemImage: "plus")
                    }
                    .accessibilityIdentifier(AFCAccessibilityID.auditsNewAuditButton)
                }
            }
        }
    }

    private var emptyState: some View {
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
    }

    private var auditList: some View {
        List {
            ForEach(audits) { audit in
                Button {
                    open(audit)
                } label: {
                    AuditListRow(audit: audit)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(AFCAccessibilityID.auditsRow)
                .listRowInsets(
                    EdgeInsets(
                        top: AFCTokens.Spacing.small,
                        leading: AFCTokens.Spacing.medium,
                        bottom: AFCTokens.Spacing.small,
                        trailing: AFCTokens.Spacing.medium
                    )
                )
                .listRowBackground(AFCTokens.Color.background)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func open(_ audit: Audit) {
        switch audit.status {
        case .draft:
            path.append(.checklist(audit.identifier))
        case .completed:
            path.append(.summary(audit.identifier))
        }
    }
}

private struct AuditListRow: View {
    let audit: Audit

    var body: some View {
        let progress = AuditReviewProgress(results: audit.items.map(\.result))

        VStack(alignment: .leading, spacing: AFCTokens.Spacing.xSmall) {
            Text(audit.title)
                .font(.headline)
                .foregroundStyle(AFCTokens.Color.primaryText)

            Text(statusText)
                .font(.subheadline)
                .foregroundStyle(AFCTokens.Color.secondaryText)

            Text(progressText(progress))
                .font(.subheadline)
                .foregroundStyle(AFCTokens.Color.secondaryText)

            Text(audit.updatedAt.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(AFCTokens.Color.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AFCTokens.Spacing.medium)
        .background(
            AFCTokens.Color.surface,
            in: RoundedRectangle(cornerRadius: AFCTokens.Radius.medium, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }

    private var statusText: String {
        switch audit.status {
        case .draft:
            String(localized: "audit.status.draft")
        case .completed:
            String(localized: "audit.status.completed")
        }
    }

    private func progressText(_ progress: AuditReviewProgress) -> String {
        String(
            format: String(localized: "audit.list.progress"),
            locale: .current,
            progress.reviewed,
            progress.total
        )
    }
}

#Preview {
    NavigationStack {
        AuditsView(path: .constant([]))
    }
    .modelContainer(for: [Audit.self, AuditItem.self], inMemory: true)
}
