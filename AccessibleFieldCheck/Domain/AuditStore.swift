//
//  AuditStore.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 15-10-26.
//

import Foundation
import SwiftData

struct AuditStore {
    private let context: ModelContext

    init(modelContext: ModelContext) {
        self.context = modelContext
    }

    @discardableResult
    func createDraft(title: String, now: Date = .now) throws -> Audit {
        let audit = Audit(
            title: title,
            createdAt: now,
            updatedAt: now,
            status: .draft
        )
        audit.items = AccessibilityCriterionCatalog.all.map { criterion in
            AuditItem(
                criterionID: criterion.id,
                result: .notReviewed,
                note: nil,
                updatedAt: now
            )
        }
        context.insert(audit)
        try context.save()
        return audit
    }

    func updateResult(item: AuditItem, result: AuditResult, now: Date = .now) throws {
        item.result = result
        item.updatedAt = now
        item.audit?.updatedAt = now
        try context.save()
    }

    func updateNote(item: AuditItem, note: String?, now: Date = .now) throws {
        item.note = normalizedNote(note)
        item.updatedAt = now
        item.audit?.updatedAt = now
        try context.save()
    }

    func complete(_ audit: Audit, now: Date = .now) throws {
        audit.status = .completed
        audit.updatedAt = now
        try context.save()
    }

    func reopen(_ audit: Audit, now: Date = .now) throws {
        audit.status = .draft
        audit.updatedAt = now
        try context.save()
    }

    func fetchAudits() throws -> [Audit] {
        let descriptor = FetchDescriptor<Audit>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    private func normalizedNote(_ note: String?) -> String? {
        guard let note, !note.isEmpty else {
            return nil
        }
        return note
    }
}
