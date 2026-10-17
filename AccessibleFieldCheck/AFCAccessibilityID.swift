//
//  AFCAccessibilityID.swift
//  AccessibleFieldCheck
//
//  Created by Nancy Hernandez on 21-09-26.
//

enum AFCAccessibilityID {
    static let auditsScreen = "audits.screen"
    static let auditsEmptyState = "audits.emptyState"
    static let auditsNewAuditButton = "audits.newAuditButton"
    static let auditsRow = "audits.row"
    static let newAuditScreen = "newAudit.screen"
    static let newAuditTitleField = "newAudit.titleField"
    static let newAuditCreateButton = "newAudit.createButton"
    static let newAuditTitleError = "newAudit.titleError"
    static let checklistScreen = "checklist.screen"
    static let checklistFinishButton = "checklist.finishButton"
    static let checklistFinishAnyway = "checklist.finishAnyway"
    static let summaryScreen = "summary.screen"
    static let summaryReopenButton = "summary.reopenButton"
    static let summaryNeedsAttentionSection = "summary.needsAttention"

    static func criterionResult(_ criterionID: String, _ result: AuditResult) -> String {
        "criterion.\(criterionID).result.\(result.rawValue)"
    }

    static func criterionNote(_ criterionID: String) -> String {
        "criterion.\(criterionID).note"
    }

    static func criterionNoteField(_ criterionID: String) -> String {
        "criterion.\(criterionID).note.field"
    }

    static func criterionNoteSave(_ criterionID: String) -> String {
        "criterion.\(criterionID).note.save"
    }

    static func summaryNeedsAttentionItem(_ criterionID: String) -> String {
        "summary.needsAttention.\(criterionID)"
    }
}
