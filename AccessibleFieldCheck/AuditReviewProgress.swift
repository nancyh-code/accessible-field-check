//
//  AuditReviewProgress.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 15-10-26.
//

struct AuditReviewProgress: Equatable, Sendable {
    let total: Int
    let reviewed: Int
    let pass: Int
    let needsAttention: Int
    let notApplicable: Int
    let notReviewed: Int

    init(results: [AuditResult]) {
        total = results.count
        pass = results.filter { $0 == .pass }.count
        needsAttention = results.filter { $0 == .needsAttention }.count
        notApplicable = results.filter { $0 == .notApplicable }.count
        notReviewed = results.filter { $0 == .notReviewed }.count
        reviewed = total - notReviewed
    }
}
