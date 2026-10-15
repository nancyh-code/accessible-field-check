//
//  AccessibilityCriterion.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 15-10-26.
//

struct AccessibilityCriterion: Hashable, Identifiable, Sendable {
    let id: String
    let titleLocalizationKey: String
    let guidanceLocalizationKey: String
    let category: CriterionCategory
    let sortOrder: Int
}

enum AccessibilityCriterionCatalog {
    static let all: [AccessibilityCriterion] = [
        AccessibilityCriterion(
            id: "dynamicType",
            titleLocalizationKey: "criterion.dynamicType.title",
            guidanceLocalizationKey: "criterion.dynamicType.guidance",
            category: .textAndContent,
            sortOrder: 1
        ),
        AccessibilityCriterion(
            id: "contentScaling",
            titleLocalizationKey: "criterion.contentScaling.title",
            guidanceLocalizationKey: "criterion.contentScaling.guidance",
            category: .textAndContent,
            sortOrder: 2
        ),
        AccessibilityCriterion(
            id: "colorContrast",
            titleLocalizationKey: "criterion.colorContrast.title",
            guidanceLocalizationKey: "criterion.colorContrast.guidance",
            category: .textAndContent,
            sortOrder: 3
        ),
        AccessibilityCriterion(
            id: "colorIndependentMeaning",
            titleLocalizationKey: "criterion.colorIndependentMeaning.title",
            guidanceLocalizationKey: "criterion.colorIndependentMeaning.guidance",
            category: .textAndContent,
            sortOrder: 4
        ),
        AccessibilityCriterion(
            id: "voiceOverLabels",
            titleLocalizationKey: "criterion.voiceOverLabels.title",
            guidanceLocalizationKey: "criterion.voiceOverLabels.guidance",
            category: .navigation,
            sortOrder: 5
        ),
        AccessibilityCriterion(
            id: "focusOrder",
            titleLocalizationKey: "criterion.focusOrder.title",
            guidanceLocalizationKey: "criterion.focusOrder.guidance",
            category: .navigation,
            sortOrder: 6
        ),
        AccessibilityCriterion(
            id: "modalAccessibility",
            titleLocalizationKey: "criterion.modalAccessibility.title",
            guidanceLocalizationKey: "criterion.modalAccessibility.guidance",
            category: .navigation,
            sortOrder: 7
        ),
        AccessibilityCriterion(
            id: "touchTargetSize",
            titleLocalizationKey: "criterion.touchTargetSize.title",
            guidanceLocalizationKey: "criterion.touchTargetSize.guidance",
            category: .interaction,
            sortOrder: 8
        ),
        AccessibilityCriterion(
            id: "formLabels",
            titleLocalizationKey: "criterion.formLabels.title",
            guidanceLocalizationKey: "criterion.formLabels.guidance",
            category: .interaction,
            sortOrder: 9
        ),
        AccessibilityCriterion(
            id: "clearButtonLabels",
            titleLocalizationKey: "criterion.clearButtonLabels.title",
            guidanceLocalizationKey: "criterion.clearButtonLabels.guidance",
            category: .interaction,
            sortOrder: 10
        ),
        AccessibilityCriterion(
            id: "reduceMotion",
            titleLocalizationKey: "criterion.reduceMotion.title",
            guidanceLocalizationKey: "criterion.reduceMotion.guidance",
            category: .interaction,
            sortOrder: 11
        ),
        AccessibilityCriterion(
            id: "errorIdentification",
            titleLocalizationKey: "criterion.errorIdentification.title",
            guidanceLocalizationKey: "criterion.errorIdentification.guidance",
            category: .feedbackAndErrors,
            sortOrder: 12
        )
    ]
}
