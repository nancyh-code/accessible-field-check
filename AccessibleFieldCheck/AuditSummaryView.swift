//
//  AuditSummaryView.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 15-10-26.
//

import SwiftData
import SwiftUI

struct AuditSummaryView: View {
    let auditID: UUID
    @Binding var path: [AppDestination]
    @Environment(\.modelContext) private var modelContext
    @Query private var audits: [Audit]

    init(auditID: UUID, path: Binding<[AppDestination]>) {
        self.auditID = auditID
        self._path = path
        let identifier = auditID
        self._audits = Query(
            filter: #Predicate<Audit> { $0.identifier == identifier }
        )
    }

    var body: some View {
        Group {
            if let currentAudit = audits.first {
                summary(for: currentAudit)
            } else {
                AFCEmptyState(title: String(localized: "audit.unavailable.title")) {
                    EmptyView()
                }
            }
        }
        .background(AFCTokens.Color.background)
        .accessibilityIdentifier(AFCAccessibilityID.summaryScreen)
        .navigationTitle(String(localized: "audit.summary.title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func summary(for audit: Audit) -> some View {
        let progress = AuditReviewProgress(results: audit.items.map(\.result))
        let needsAttention = needsAttentionRows(in: audit)

        return List {
            Section {
                Text(audit.title)
                    .font(.title2)
                    .foregroundStyle(AFCTokens.Color.primaryText)
                    .accessibilityAddTraits(.isHeader)
                Text(statusText(audit.status))
                    .font(.body)
                    .foregroundStyle(AFCTokens.Color.secondaryText)
            }

            Section {
                countRow("audit.summary.count.total", value: progress.total)
                countRow("audit.summary.count.pass", value: progress.pass)
                countRow("audit.summary.count.needsAttention", value: progress.needsAttention)
                countRow("audit.summary.count.notApplicable", value: progress.notApplicable)
                countRow("audit.summary.count.notReviewed", value: progress.notReviewed)
            }

            Section {
                if needsAttention.isEmpty {
                    Text(String(localized: "audit.summary.needsAttention.empty"))
                        .font(.body)
                        .foregroundStyle(AFCTokens.Color.secondaryText)
                } else {
                    ForEach(needsAttention, id: \.item.identifier) { row in
                        VStack(alignment: .leading, spacing: AFCTokens.Spacing.xSmall) {
                            Text(localized(row.criterion.titleLocalizationKey))
                                .font(.headline)
                                .foregroundStyle(AFCTokens.Color.primaryText)
                            AFCStatusBadge(status: .needsAttention)
                            if let note = row.item.note, !note.isEmpty {
                                Text(note)
                                    .font(.body)
                                    .foregroundStyle(AFCTokens.Color.secondaryText)
                            }
                        }
                        .padding(.vertical, AFCTokens.Spacing.xSmall)
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier(
                            AFCAccessibilityID.summaryNeedsAttentionItem(row.criterion.id)
                        )
                    }
                }
            } header: {
                Text(String(localized: "audit.summary.needsAttention.section"))
                    .accessibilityIdentifier(AFCAccessibilityID.summaryNeedsAttentionSection)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .toolbar {
            if audit.status == .completed {
                ToolbarItem(placement: .bottomBar) {
                    AFCPrimaryButton(
                        title: String(localized: "audit.summary.reopen"),
                        accessibilityIdentifier: AFCAccessibilityID.summaryReopenButton
                    ) {
                        reopen(audit)
                    }
                }
            }
        }
    }

    private func reopen(_ audit: Audit) {
        let store = AuditStore(modelContext: modelContext)
        guard (try? store.reopen(audit)) != nil else {
            return
        }
        path.removeAll { $0 == .summary(auditID) }
        path.append(.checklist(auditID))
    }

    private func needsAttentionRows(in audit: Audit) -> [NeedsAttentionRow] {
        let itemsByID = Dictionary(uniqueKeysWithValues: audit.items.map { ($0.criterionID, $0) })
        return AccessibilityCriterionCatalog.all.compactMap { criterion in
            guard let item = itemsByID[criterion.id], item.result == .needsAttention else {
                return nil
            }
            return NeedsAttentionRow(criterion: criterion, item: item)
        }
    }

    private func countRow(_ key: String, value: Int) -> some View {
        Text(
            String(
                format: String(localized: String.LocalizationValue(key)),
                locale: .current,
                value
            )
        )
        .font(.body)
        .foregroundStyle(AFCTokens.Color.primaryText)
    }

    private func statusText(_ status: AuditStatus) -> String {
        switch status {
        case .draft:
            String(localized: "audit.status.draft")
        case .completed:
            String(localized: "audit.status.completed")
        }
    }

    private func localized(_ key: String) -> String {
        String(localized: String.LocalizationValue(key))
    }
}

private struct NeedsAttentionRow {
    let criterion: AccessibilityCriterion
    let item: AuditItem
}

#Preview {
    NavigationStack {
        AuditSummaryView(auditID: UUID(), path: .constant([]))
    }
    .modelContainer(for: [Audit.self, AuditItem.self], inMemory: true)
}
