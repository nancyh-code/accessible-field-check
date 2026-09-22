//
//  AccessibleFieldCheckTests.swift
//  AccessibleFieldCheckTests
//
//  Created by Nancy Hernandez on 21-09-26.
//

import CoreGraphics
import Testing
@testable import AccessibleFieldCheck

@MainActor
struct DesignSystemTests {

    @Test func spacingTokensMatchContract() {
        #expect(AFCTokens.Spacing.xSmall == CGFloat(4))
        #expect(AFCTokens.Spacing.small == CGFloat(8))
        #expect(AFCTokens.Spacing.medium == CGFloat(16))
        #expect(AFCTokens.Spacing.large == CGFloat(24))
        #expect(AFCTokens.Spacing.xLarge == CGFloat(32))
    }

    @Test func radiusTokensMatchContract() {
        #expect(AFCTokens.Radius.small == CGFloat(8))
        #expect(AFCTokens.Radius.medium == CGFloat(12))
        #expect(AFCTokens.Radius.large == CGFloat(16))
    }

    @Test func statusRepresentationsIncludeIconAndText() {
        #expect(AFCStatus.allCases == [.pass, .needsAttention, .notApplicable])

        #expect(AFCStatus.pass.symbolName == "checkmark.circle.fill")
        #expect(AFCStatus.needsAttention.symbolName == "exclamationmark.triangle.fill")
        #expect(AFCStatus.notApplicable.symbolName == "minus.circle.fill")

        #expect(AFCStatus.pass.titleKey == "designSystem.status.pass")
        #expect(AFCStatus.needsAttention.titleKey == "designSystem.status.needsAttention")
        #expect(AFCStatus.notApplicable.titleKey == "designSystem.status.notApplicable")

        for status in AFCStatus.allCases {
            #expect(!status.title.isEmpty)
            #expect(!status.symbolName.isEmpty)
        }
    }
}
