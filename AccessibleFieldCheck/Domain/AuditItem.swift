//
//  AuditItem.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 15-10-26.
//

import Foundation

struct AuditItem: Hashable, Identifiable, Sendable {
    var identifier: UUID
    var criterionID: String
    var result: AuditResult
    var note: String?
    var updatedAt: Date

    var id: UUID { identifier }

    init(
        identifier: UUID = UUID(),
        criterionID: String,
        result: AuditResult = .notReviewed,
        note: String? = nil,
        updatedAt: Date = .now
    ) {
        self.identifier = identifier
        self.criterionID = criterionID
        self.result = result
        self.note = note
        self.updatedAt = updatedAt
    }
}
