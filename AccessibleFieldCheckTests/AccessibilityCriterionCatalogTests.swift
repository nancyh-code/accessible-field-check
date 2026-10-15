//
//  AccessibilityCriterionCatalogTests.swift
//  AccessibleFieldCheckTests
//
//  Created by Nancy Hernandez on 15-10-26.
//

import Testing
@testable import AccessibleFieldCheck

@MainActor
struct AccessibilityCriterionCatalogTests {

    private let expectedIDs: Set<String> = [
        "dynamicType",
        "voiceOverLabels",
        "touchTargetSize",
        "colorContrast",
        "colorIndependentMeaning",
        "focusOrder",
        "errorIdentification",
        "formLabels",
        "modalAccessibility",
        "reduceMotion",
        "contentScaling",
        "clearButtonLabels"
    ]

    @Test func catalogContainsExactlyTwelveUniqueRequiredIDs() {
        let criteria = AccessibilityCriterionCatalog.all
        let ids = criteria.map(\.id)

        #expect(criteria.count == 12)
        #expect(Set(ids).count == 12)
        #expect(Set(ids) == expectedIDs)
    }

    @Test func catalogSortOrderIsDeterministicOneThroughTwelve() {
        let sortOrders = AccessibilityCriterionCatalog.all.map(\.sortOrder)

        #expect(sortOrders == Array(1...12))
    }

    @Test func catalogUsesLocalizationKeysNotDisplayStrings() {
        for criterion in AccessibilityCriterionCatalog.all {
            #expect(!criterion.titleLocalizationKey.isEmpty)
            #expect(!criterion.guidanceLocalizationKey.isEmpty)
            #expect(criterion.titleLocalizationKey == "criterion.\(criterion.id).title")
            #expect(criterion.guidanceLocalizationKey == "criterion.\(criterion.id).guidance")
        }
    }
}
