import XCTest

/// Not a test suite - a scripted driver. driver.sh passes a step list in
/// DRIVER_STEPS (via xcodebuild's TEST_RUNNER_ env prefix) and this runs
/// them against the real app in the Simulator, writing PNGs to SHOT_DIR.
///
/// Steps are separated by ";", each is "verb" or "verb:arg":
///   tab:<label>      tap a tab bar item (Health, Social, Home, Hobbies, Career)
///   tap:<label>      tap the first button with that label / identifier
///   text:<label>     tap the first static text with that label
///   type:<text>      type into the currently focused field
///   field:<label>    tap the first text field whose placeholder/label matches
///   back             tap the nav bar back button
///   wait:<seconds>   sleep
///   shot:<name>      screenshot -> $SHOT_DIR/<name>.png
///   tree:<name>      dump the accessibility hierarchy -> $SHOT_DIR/<name>.txt
final class DriverUITests: XCTestCase {
    func testDrive() throws {
        let env = ProcessInfo.processInfo.environment
        let steps = (env["DRIVER_STEPS"] ?? "shot:home")
            .split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let shotDir = env["SHOT_DIR"] ?? NSTemporaryDirectory()
        try FileManager.default.createDirectory(atPath: shotDir, withIntermediateDirectories: true)

        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15), "tab bar never appeared")

        for step in steps {
            let parts = step.split(separator: ":", maxSplits: 1).map(String.init)
            let verb = parts[0], arg = parts.count > 1 ? parts[1] : ""
            print("DRIVER step: \(step)")
            switch verb {
            case "tab":
                try tapOrFail(app.tabBars.buttons[arg], step)
            case "tap":
                try tapOrFail(app.buttons[arg].firstMatch, step)
            case "text":
                try tapOrFail(app.staticTexts[arg].firstMatch, step)
            case "field":
                try tapOrFail(app.textFields[arg].firstMatch, step)
            case "type":
                app.typeText(arg)
            case "back":
                try tapOrFail(app.navigationBars.buttons.element(boundBy: 0), step)
            case "wait":
                Thread.sleep(forTimeInterval: Double(arg) ?? 1)
            case "shot":
                Thread.sleep(forTimeInterval: 0.6) // let animations settle
                let path = (shotDir as NSString).appendingPathComponent("\(arg.isEmpty ? "shot" : arg).png")
                try XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: path))
                print("DRIVER shot: \(path)")
            case "tree":
                let path = (shotDir as NSString).appendingPathComponent("\(arg.isEmpty ? "tree" : arg).txt")
                try app.debugDescription.write(toFile: path, atomically: true, encoding: .utf8)
                print("DRIVER tree: \(path)")
            default:
                XCTFail("DRIVER unknown step: \(step)")
            }
        }
    }

    private func tapOrFail(_ el: XCUIElement, _ step: String) throws {
        guard el.waitForExistence(timeout: 5) else {
            XCTFail("DRIVER no element for step '\(step)' - run with 'tree' to see labels")
            throw XCTSkip("aborting")
        }
        el.tap()
    }
}
