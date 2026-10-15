//
//  CriterionCategory.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 15-10-26.
//

enum CriterionCategory: String, Hashable, CaseIterable, Sendable {
    case textAndContent
    case interaction
    case navigation
    case feedbackAndErrors

    var localizationKey: String {
        "criterionCategory.\(rawValue)"
    }
}
