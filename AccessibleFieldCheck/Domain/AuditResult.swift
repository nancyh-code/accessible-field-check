//
//  AuditResult.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 15-10-26.
//

enum AuditResult: String, Hashable, CaseIterable, Sendable {
    case notReviewed
    case pass
    case needsAttention
    case notApplicable
}
