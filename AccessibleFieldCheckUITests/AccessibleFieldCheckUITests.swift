//
//  AccessibleFieldCheckUITests.swift
//  AccessibleFieldCheckUITests
//
//  Created by Nancy Hernandez on 21-09-26.
//

import XCTest

final class AuditFlowUITests: XCTestCase {
    private let auditTitle = "UI Test Audit"
    private let needsAttentionNote = "Increase tap target size."
    private let passCriterionID = "dynamicType"
    private let needsAttentionCriterionID = "contentScaling"

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testHappyPathCreatesReviewFinishesAndPersistsAudit() throws {
        let app = launchIsolatedApp()

        XCTAssertTrue(
            element(in: app, identifier: "audits.screen").waitForExistence(timeout: 8),
            "Audits screen should be visible after launch."
        )
        XCTAssertTrue(
            element(in: app, identifier: "audits.emptyState").waitForExistence(timeout: 4),
            "Empty store should show the Audits empty state."
        )

        let newAuditButton = app.buttons["audits.newAuditButton"]
        XCTAssertTrue(newAuditButton.waitForExistence(timeout: 4))
        newAuditButton.tap()

        XCTAssertTrue(
            element(in: app, identifier: "newAudit.screen").waitForExistence(timeout: 8),
            "New Audit should open from the empty-state action."
        )

        let titleField = app.textFields["newAudit.titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 4))
        titleField.tap()
        titleField.typeText(auditTitle)
        app.buttons["newAudit.createButton"].tap()

        XCTAssertTrue(
            element(in: app, identifier: "checklist.screen").waitForExistence(timeout: 8),
            "Creating an audit should open the checklist."
        )

        tapResult(in: app, criterionID: passCriterionID, result: "pass")
        tapResult(in: app, criterionID: needsAttentionCriterionID, result: "needsAttention")
        addNote(in: app, criterionID: needsAttentionCriterionID, note: needsAttentionNote)

        let finish = element(in: app, identifier: "checklist.finishButton")
        XCTAssertTrue(finish.waitForExistence(timeout: 8), "Finish Audit should remain discoverable.")
        finish.tap()
        confirmFinishIfNeeded(in: app)

        XCTAssertTrue(
            element(in: app, identifier: "summary.screen").waitForExistence(timeout: 8),
            "Finishing should replace the checklist with the summary."
        )

        let needsAttentionItem = element(
            in: app,
            identifier: "summary.needsAttention.\(needsAttentionCriterionID)"
        )
        XCTAssertTrue(
            needsAttentionItem.waitForExistence(timeout: 4),
            "Summary should represent the needs-attention criterion."
        )
        XCTAssertTrue(
            app.staticTexts[needsAttentionNote].waitForExistence(timeout: 4),
            "Summary should represent the needs-attention note."
        )

        popNavigation(in: app)

        XCTAssertTrue(element(in: app, identifier: "audits.screen").waitForExistence(timeout: 8))
        XCTAssertFalse(
            element(in: app, identifier: "audits.emptyState").exists,
            "Persisted audits should replace the empty state."
        )
        XCTAssertTrue(
            element(in: app, identifier: "audits.row").waitForExistence(timeout: 4),
            "Audits should show the persisted review."
        )
        XCTAssertTrue(app.staticTexts[auditTitle].exists)
    }

    @MainActor
    func testEmptyTitleShowsValidationAndDoesNotCreateAudit() throws {
        let app = launchIsolatedApp()

        XCTAssertTrue(element(in: app, identifier: "audits.screen").waitForExistence(timeout: 8))
        XCTAssertTrue(element(in: app, identifier: "audits.emptyState").waitForExistence(timeout: 4))

        app.buttons["audits.newAuditButton"].tap()
        XCTAssertTrue(element(in: app, identifier: "newAudit.screen").waitForExistence(timeout: 8))

        app.buttons["newAudit.createButton"].tap()

        XCTAssertTrue(
            element(in: app, identifier: "newAudit.titleError").waitForExistence(timeout: 4),
            "Empty title should expose an accessible validation message."
        )
        XCTAssertTrue(
            element(in: app, identifier: "newAudit.screen").exists,
            "Invalid create should remain on New Audit."
        )
        XCTAssertFalse(
            element(in: app, identifier: "checklist.screen").exists,
            "Invalid create should not open the checklist."
        )

        popNavigation(in: app)

        XCTAssertTrue(element(in: app, identifier: "audits.screen").waitForExistence(timeout: 8))
        XCTAssertTrue(
            element(in: app, identifier: "audits.emptyState").waitForExistence(timeout: 4),
            "Rejected create should not persist an audit row."
        )
        XCTAssertFalse(element(in: app, identifier: "audits.row").exists)
    }

    private func launchIsolatedApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing-empty-store"]
        app.launch()
        return app
    }

    private func tapResult(in app: XCUIApplication, criterionID: String, result: String) {
        tapWhenAvailable(
            app.buttons["criterion.\(criterionID).result.\(result)"],
            in: app
        )
    }

    private func addNote(in app: XCUIApplication, criterionID: String, note: String) {
        let noteButton = app.buttons["criterion.\(criterionID).note"]
        revealForTap(noteButton, in: app)
        noteButton.tap()

        let field = element(in: app, identifier: "criterion.\(criterionID).note.field")
        XCTAssertTrue(field.waitForExistence(timeout: 6), "Note field should expand inline.")
        revealForTap(field, in: app)
        XCTAssertTrue(field.isHittable, "Note field should expand inline.")
        field.tap()
        field.typeText(note)
        app.navigationBars.firstMatch.tap()

        let save = app.buttons["criterion.\(criterionID).note.save"]
        revealForTap(save, in: app)
        save.tap()
    }

    private func revealForTap(_ element: XCUIElement, in app: XCUIApplication) {
        XCTAssertTrue(element.waitForExistence(timeout: 8), "Expected \(element.identifier) to exist.")
        let window = app.windows.firstMatch
        for _ in 0..<5 {
            if isReadyToTap(element, in: window) {
                return
            }
            if element.frame.midY < window.frame.midY {
                app.swipeDown()
            } else {
                app.swipeUp()
            }
        }
        XCTAssertTrue(isReadyToTap(element, in: window), "Expected \(element.identifier) to be on screen.")
    }

    private func isReadyToTap(_ element: XCUIElement, in window: XCUIElement) -> Bool {
        guard element.exists, element.isHittable else {
            return false
        }
        var visible = window.frame
        visible.origin.y += 64
        visible.size.height = max(0, visible.height - 64 - 88)
        return visible.contains(CGPoint(x: element.frame.midX, y: element.frame.midY))
    }

    private func confirmFinishIfNeeded(in app: XCUIApplication) {
        let finishAnyway = element(in: app, identifier: "checklist.finishAnyway")
        if finishAnyway.waitForExistence(timeout: 4) {
            finishAnyway.tap()
            return
        }

        let sheetButtons = app.sheets.buttons
        if sheetButtons.count > 0 {
            sheetButtons.element(boundBy: 0).tap()
        }
    }

    private func popNavigation(in app: XCUIApplication) {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 4), "Back should remain available.")
        backButton.tap()
    }

    private func tapWhenAvailable(_ element: XCUIElement, in app: XCUIApplication) {
        XCTAssertTrue(element.waitForExistence(timeout: 8), "Expected \(element.identifier) to exist.")
        if !element.isHittable {
            app.swipeUp()
        }
        element.tap()
    }

    private func element(in app: XCUIApplication, identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }
}
