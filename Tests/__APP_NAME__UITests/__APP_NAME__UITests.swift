import XCTest

/// Baseline UI test so the `ui_test` lane has a target to compile and run.
/// Launches the app and confirms the placeholder screen renders.
final class __APP_NAME__UITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchRendersHomeScreen() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Hello, __APP_NAME__"].waitForExistence(timeout: 10))
    }
}
