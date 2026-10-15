//
//  Audit.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 15-10-26.
//

import Foundation

struct Audit: Hashable, Identifiable, Sendable {
    var identifier: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var status: AuditStatus
    var items: [AuditItem]

    var id: UUID { identifier }

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
        self.status = status
        self.items = items
    }
}
