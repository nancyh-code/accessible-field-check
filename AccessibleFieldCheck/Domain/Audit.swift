//
//  Audit.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 15-10-26.
//

import Foundation
import SwiftData

@Model
final class Audit {
    var identifier: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date
    /// SwiftData stores `AuditStatus` as its `String` raw value.
    var statusRaw: String
    @Relationship(deleteRule: .cascade, inverse: \AuditItem.audit)
    var items: [AuditItem]

    var status: AuditStatus {
        get { AuditStatus(rawValue: statusRaw) ?? .draft }
        set { statusRaw = newValue.rawValue }
    }

    init(
        identifier: UUID = UUID(),
        title: String,
        createdAt: Date = .now,
        updatedAt: Date? = nil,
        status: AuditStatus = .draft,
        items: [AuditItem] = []
    ) {
        self.identifier = identifier
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt
        self.statusRaw = status.rawValue
        self.items = items
    }
}
