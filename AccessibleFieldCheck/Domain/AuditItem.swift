//
//  AuditItem.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 15-10-26.
//

import Foundation
import SwiftData

@Model
final class AuditItem {
    var identifier: UUID
    var criterionID: String
    /// SwiftData stores `AuditResult` as its `String` raw value.
    var resultRaw: String
    var note: String?
    var updatedAt: Date
    var audit: Audit?

    var result: AuditResult {
        get { AuditResult(rawValue: resultRaw) ?? .notReviewed }
        set { resultRaw = newValue.rawValue }
    }

    init(
        identifier: UUID = UUID(),
        criterionID: String,
        result: AuditResult = .notReviewed,
        note: String? = nil,
        updatedAt: Date = .now
    ) {
        self.identifier = identifier
        self.criterionID = criterionID
        self.resultRaw = result.rawValue
        self.note = note
        self.updatedAt = updatedAt
    }
}
