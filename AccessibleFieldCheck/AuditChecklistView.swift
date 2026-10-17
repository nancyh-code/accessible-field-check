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
        .safeAreaInset(edge: .bottom) {
            AFCPrimaryButton(
                title: String(localized: "audit.checklist.finish"),
                accessibilityIdentifier: AFCAccessibilityID.checklistFinishButton
            ) {
                attemptFinish(audit, progress: progress)
            }
            .padding(AFCTokens.Spacing.medium)
            .background(AFCTokens.Color.background)
        }
        .confirmationDialog(
            String(localized: "audit.checklist.finishConfirm.title"),
            isPresented: $showsFinishConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "audit.checklist.finishAnyway")) {
                complete(audit)
            }
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

            AuditResultControl(selected: item.result) { result in
                updateResult(item, result: result)
            }

            DisclosureGroup(
                String(localized: "audit.checklist.note"),
                isExpanded: noteExpanded(item)
            ) {
                VStack(alignment: .leading, spacing: AFCTokens.Spacing.small) {
                    TextField(
                        String(localized: "audit.checklist.note.placeholder"),
                        text: noteDraft(item),
                        axis: .vertical
                    )
                    .font(.body)
                    .lineLimit(3...8)
                    .textFieldStyle(.roundedBorder)

                    AFCPrimaryButton(title: String(localized: "audit.checklist.note.save")) {
                        saveNote(item)
                    }

                    if item.note != nil {
                        Button(String(localized: "audit.checklist.note.remove"), role: .destructive) {
                            removeNote(item)
                        }
                        .frame(minHeight: 44)
                    }
                }
                .padding(.top, AFCTokens.Spacing.xSmall)
            }
        }
        .padding(.vertical, AFCTokens.Spacing.xSmall)
        .accessibilityElement(children: .contain)
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

    private func noteExpanded(_ item: AuditItem) -> Binding<Bool> {
        Binding(
            get: { expandedNoteIDs.contains(item.identifier) },
            set: { expanded in
                if expanded {
                    expandedNoteIDs.insert(item.identifier)
                    if noteDrafts[item.identifier] == nil {
                        noteDrafts[item.identifier] = item.note ?? ""
                    }
                } else {
                    saveNote(item)
                }
            }
        )
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
    let selected: AuditResult
    let onSelect: (AuditResult) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 140), spacing: AFCTokens.Spacing.small)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: AFCTokens.Spacing.small) {
            ForEach(AFCStatus.allCases, id: \.self) { status in
                resultButton(status)
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
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    NavigationStack {
        AuditChecklistView(auditID: UUID(), path: .constant([]))
    }
    .modelContainer(for: [Audit.self, AuditItem.self], inMemory: true)
}
