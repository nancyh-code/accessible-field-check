//
//  AccessibleFieldCheckUITests.swift
//  AccessibleFieldCheckUITests
//
//  Created by Nancy Hernandez on 21-09-26.
//

import XCTest

final class AuditsSmokeUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchShowsAuditsAndOpensNewAuditPlaceholder() throws {
        let app = XCUIApplication()
        app.launch()

        let auditsScreen = element(in: app, identifier: "audits.screen")
        XCTAssertTrue(auditsScreen.waitForExistence(timeout: 8), "Audits screen should be visible after launch.")

        let newAuditButton = app.buttons["audits.newAuditButton"]
        XCTAssertTrue(newAuditButton.waitForExistence(timeout: 4), "New Audit CTA should exist.")
        XCTAssertTrue(newAuditButton.isHittable, "New Audit CTA should be hittable.")

        newAuditButton.tap()

        let newAuditScreen = element(in: app, identifier: "newAudit.screen")
        XCTAssertTrue(newAuditScreen.waitForExistence(timeout: 8), "New Audit placeholder should appear after tapping the CTA.")
    }

    private func element(in app: XCUIApplication, identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }
}
