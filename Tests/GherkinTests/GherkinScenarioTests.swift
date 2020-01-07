import Consumer
@testable import Gherkin
import XCTest

class GherkinScenarioTests: XCTestCase {
    var feature: Feature!
    var scenario: Scenario!

    override func setUp() {
        super.setUp()
        feature = try! Feature(#file, featurePath: "features/MyTest.feature")
        scenario = try! feature.scenario(for: "A Scenario")
    }

    func testStepShouldExist() {
        XCTAssertNotNil(try! scenario.step(for: "I am a given"))
    }

    func testStepShouldBeCaseInsensitive() {
        XCTAssertNotNil(try! scenario.step(for: "i Am a Given"))
    }

    func testStepShouldNotExist() {
        XCTAssertThrowsError(try scenario.step(for: "I am a not a step")) { error in
            XCTAssertEqual(error as! SearchError, SearchError.notFound)
        }
    }

    func testStepBadRegex() {
        XCTAssertThrowsError(try scenario.step(for: "[")) { error in
            XCTAssertNotNil(error)
            XCTAssertEqual((error as NSError).code, 2048)
        }
    }

    func testSimpleScenarioHasNoExamples() throws {
        let text = """
        Feature: Minimal Scenario
        Scenario: minimalistic
        Given I am a mountain
        And I love chocolate
        """

        let result = try Feature(text)
        XCTAssertNil(result.scenarios.first?.examples)
    }

    func testScenarioOutlineHasName() throws {
        let text = """
        Feature: Minimal Scenario Outline

        Scenario Outline: minimalistic
        Given I am a mountain
        And I love chocolate
        And I love chocolate

        Examples:
        | mountain |
        | etna     |
        | another  |
        | another  |
        | another  |
        | another  |
        """

        let result = try Feature(text)
        XCTAssertTrue(result.scenarios.first?.name == "minimalistic")
    }

    static var allTests = [
        ("testStepShouldExist", testStepShouldExist),
        ("testStepShouldBeCaseInsensitive", testStepShouldBeCaseInsensitive),
        ("testStepShouldNotExist", testStepShouldNotExist),
        ("testStepBadRegex", testStepBadRegex),
        ("testSimpleScenarioHasNoExamples", testSimpleScenarioHasNoExamples),
        ("testScenarioOutlineHasName", testScenarioOutlineHasName),
    ]
}
