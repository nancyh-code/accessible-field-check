//
//  AuditChecklistView.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 15-10-26.
//

import SwiftData
import SwiftUI

struct AuditChecklistView: View {
    let auditID: UUID
    @Binding var path: [AppDestination]
    @Environment(\.modelContext) private var modelContext
    @Query private var audits: [Audit]
    @State private var showsFinishConfirmation = false
    @State private var expandedNoteIDs: Set<UUID> = []
    @State private var noteDrafts: [UUID: String] = [:]

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
            if let currentAudit {
                checklist(for: currentAudit)
            } else {
                unavailableState
            }
        }
        .background(AFCTokens.Color.background)
        .accessibilityIdentifier(AFCAccessibilityID.checklistScreen)
        .navigationTitle(String(localized: "audit.checklist.title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var currentAudit: Audit? {
        audits.first
    }

    private var unavailableState: some View {
        AFCEmptyState(title: String(localized: "audit.unavailable.title")) {
            EmptyView()
        }
    }

    private func checklist(for audit: Audit) -> some View {
        let progress = AuditReviewProgress(results: audit.items.map(\.result))

        return List {
            Section {
                Text(progressText(progress))
                    .font(.body)
                    .foregroundStyle(AFCTokens.Color.primaryText)
                    .accessibilityAddTraits(.isHeader)
            }

            ForEach(groupedCriteria(in: audit), id: \.category) { group in
                Section(categoryTitle(group.category)) {
                    ForEach(group.rows, id: \.item.identifier) { row in
                        criterionRow(row.criterion, item: row.item, in: audit)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                AFCPrimaryButton(
                    title: String(localized: "audit.checklist.finish"),
                    accessibilityIdentifier: AFCAccessibilityID.checklistFinishButton
                ) {
                    attemptFinish(audit, progress: progress)
                }
            }
        }
        .confirmationDialog(
            String(localized: "audit.checklist.finishConfirm.title"),
            isPresented: $showsFinishConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "audit.checklist.finishAnyway")) {
                complete(audit)
            }
            .accessibilityIdentifier(AFCAccessibilityID.checklistFinishAnyway)
            Button(String(localized: "audit.checklist.cancel"), role: .cancel) {}
        } message: {
            Text(unreviewedMessage(progress.notReviewed))
        }
    }

    private func criterionRow(
        _ criterion: AccessibilityCriterion,
        item: AuditItem,
        in audit: Audit
    ) -> some View {
        VStack(alignment: .leading, spacing: AFCTokens.Spacing.small) {
            Text(localized(criterion.titleLocalizationKey))
                .font(.headline)
                .foregroundStyle(AFCTokens.Color.primaryText)

            Text(localized(criterion.guidanceLocalizationKey))
                .font(.body)
                .foregroundStyle(AFCTokens.Color.secondaryText)

            AuditResultControl(criterionID: criterion.id, selected: item.result) { result in
                updateResult(item, result: result)
            }

            Button {
                toggleNote(item)
            } label: {
                Label(
                    String(localized: "audit.checklist.note"),
                    systemImage: expandedNoteIDs.contains(item.identifier) ? "chevron.down" : "chevron.right"
                )
                .font(.body)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AFCAccessibilityID.criterionNote(criterion.id))
            .accessibilityAddTraits(expandedNoteIDs.contains(item.identifier) ? .isSelected : [])

            if expandedNoteIDs.contains(item.identifier) {
                VStack(alignment: .leading, spacing: AFCTokens.Spacing.small) {
                    TextEditor(text: noteDraft(item))
                        .font(.body)
                        .frame(minHeight: 88)
                        .accessibilityLabel(String(localized: "audit.checklist.note"))
                        .accessibilityIdentifier(AFCAccessibilityID.criterionNoteField(criterion.id))

                    AFCPrimaryButton(
                        title: String(localized: "audit.checklist.note.save"),
                        accessibilityIdentifier: AFCAccessibilityID.criterionNoteSave(criterion.id)
                    ) {
                        saveNote(item)
                    }

                    if item.note != nil {
                        Button(String(localized: "audit.checklist.note.remove"), role: .destructive) {
                            removeNote(item)
                        }
                        .frame(minHeight: 44)
                    }
                }
            }
        }
        .padding(.vertical, AFCTokens.Spacing.xSmall)
    }

    private func attemptFinish(_ audit: Audit, progress: AuditReviewProgress) {
        if progress.notReviewed == 0 {
            complete(audit)
        } else {
            showsFinishConfirmation = true
        }
    }

    private func complete(_ audit: Audit) {
        let store = AuditStore(modelContext: modelContext)
        guard (try? store.complete(audit)) != nil else {
            return
        }
        path.removeAll { $0 == .checklist(auditID) }
        path.append(.summary(auditID))
    }

    private func updateResult(_ item: AuditItem, result: AuditResult) {
        let store = AuditStore(modelContext: modelContext)
        _ = try? store.updateResult(item: item, result: result)
    }

    private func saveNote(_ item: AuditItem) {
        let store = AuditStore(modelContext: modelContext)
        let draft = noteDrafts[item.identifier] ?? item.note
        _ = try? store.updateNote(item: item, note: draft)
        expandedNoteIDs.remove(item.identifier)
    }

    private func removeNote(_ item: AuditItem) {
        let store = AuditStore(modelContext: modelContext)
        _ = try? store.updateNote(item: item, note: nil)
        noteDrafts[item.identifier] = ""
        expandedNoteIDs.remove(item.identifier)
    }

    private func toggleNote(_ item: AuditItem) {
        if expandedNoteIDs.contains(item.identifier) {
            saveNote(item)
            return
        }

        expandedNoteIDs.insert(item.identifier)
        if noteDrafts[item.identifier] == nil {
            noteDrafts[item.identifier] = item.note ?? ""
        }
    }

    private func noteDraft(_ item: AuditItem) -> Binding<String> {
        Binding(
            get: { noteDrafts[item.identifier] ?? item.note ?? "" },
            set: { noteDrafts[item.identifier] = $0 }
        )
    }

    private func groupedCriteria(in audit: Audit) -> [CriterionGroup] {
        let itemsByID = Dictionary(uniqueKeysWithValues: audit.items.map { ($0.criterionID, $0) })
        return CriterionCategory.allCases.compactMap { category in
            let rows = AccessibilityCriterionCatalog.all.compactMap { criterion -> CriterionRow? in
                guard criterion.category == category, let item = itemsByID[criterion.id] else {
                    return nil
                }
                return CriterionRow(criterion: criterion, item: item)
            }
            guard !rows.isEmpty else {
                return nil
            }
            return CriterionGroup(category: category, rows: rows)
        }
    }

    private func categoryTitle(_ category: CriterionCategory) -> String {
        localized(category.localizationKey)
    }

    private func localized(_ key: String) -> String {
        String(localized: String.LocalizationValue(key))
    }

    private func progressText(_ progress: AuditReviewProgress) -> String {
        String(
            format: String(localized: "audit.list.progress"),
            locale: .current,
            progress.reviewed,
            progress.total
        )
    }

    private func unreviewedMessage(_ count: Int) -> String {
        String(
            format: String(localized: "audit.checklist.finishConfirm.message"),
            locale: .current,
            count
        )
    }
}

private struct CriterionGroup {
    let category: CriterionCategory
    let rows: [CriterionRow]
}

private struct CriterionRow {
    let criterion: AccessibilityCriterion
    let item: AuditItem
}

private struct AuditResultControl: View {
    let criterionID: String
    let selected: AuditResult
    let onSelect: (AuditResult) -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let columns = [
        GridItem(.adaptive(minimum: 140), spacing: AFCTokens.Spacing.small)
    ]

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: AFCTokens.Spacing.small) {
                    ForEach(AFCStatus.allCases, id: \.self, content: resultButton)
                }
            } else {
                LazyVGrid(columns: columns, alignment: .leading, spacing: AFCTokens.Spacing.small) {
                    ForEach(AFCStatus.allCases, id: \.self, content: resultButton)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func resultButton(_ status: AFCStatus) -> some View {
        let isSelected = status.result == selected

        return Button {
            onSelect(status.result)
        } label: {
            Label(status.title, systemImage: status.symbolName)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .foregroundStyle(status.color)
                .padding(.horizontal, AFCTokens.Spacing.small)
                .padding(.vertical, AFCTokens.Spacing.small)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    status.color.opacity(isSelected ? 0.22 : 0.08),
                    in: RoundedRectangle(cornerRadius: AFCTokens.Radius.small, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AFCTokens.Radius.small, style: .continuous)
                        .strokeBorder(isSelected ? status.color : .clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(AFCAccessibilityID.criterionResult(criterionID, status.result))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    NavigationStack {
        AuditChecklistView(auditID: UUID(), path: .constant([]))
    }
    .modelContainer(for: [Audit.self, AuditItem.self], inMemory: true)
}
