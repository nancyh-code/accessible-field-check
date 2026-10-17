//
//  AuditReviewProgressTests.swift
//  AccessibleFieldCheckTests
//
//  Created by Nancy Hernandez on 15-10-26.
//

import Testing
@testable import AccessibleFieldCheck

struct AuditReviewProgressTests {

    @Test func countsReviewedAndResultTallies() {
        let progress = AuditReviewProgress(
            results: [
                .pass,
                .pass,
                .needsAttention,
                .notApplicable,
                .notReviewed,
                .notReviewed
            ]
        )

        #expect(progress.total == 6)
        #expect(progress.reviewed == 4)
        #expect(progress.pass == 2)
        #expect(progress.needsAttention == 1)
        #expect(progress.notApplicable == 1)
        #expect(progress.notReviewed == 2)
    }

    @Test func emptyResultsAreZero() {
        let progress = AuditReviewProgress(results: [])

        #expect(progress.total == 0)
        #expect(progress.reviewed == 0)
        #expect(progress.pass == 0)
        #expect(progress.needsAttention == 0)
        #expect(progress.notApplicable == 0)
        #expect(progress.notReviewed == 0)
    }
}
