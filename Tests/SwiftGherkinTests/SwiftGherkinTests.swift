import XCTest
@testable import SwiftGherkin
import Consumer

class SwiftGherkinTests: XCTestCase {
    func testParsingSimpleFeatureFile() throws {
        let text = """
                   Feature: Minimal Scenario Outline

                   Scenario: minimalistic
                   Given I am a mountain
                   And I love chocolate
                   """


        let result = try transformed(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertTrue(result.scenarios.first?.steps.count == 2)
        XCTAssertTrue(result.scenarios.first?.steps[0].text == "I am a mountain")
    }

    func testParsingSimpleFeatureFileWithVariable() throws {
        let text = """
                   Feature: Minimal Scenario Outline

                   Scenario Outline: minimalistic
                   Given I am a mountain
                   And I love chocolate
                   """



        let result = try transformed(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertTrue(result.scenarios.first?.steps.count == 2)
        if case Scenario.simple = result.scenarios.first!   {
            XCTFail()
        }
    }

    func testParsingFeatureFileWithMultipleScenarios() throws {
        let text = """
                   Feature: Minimal Scenario Outline

                   Scenario: minimalistic
                   Given I am a mountain
                   And I love chocolate
                   And I love chocolate

                   Scenario: minimalistic
                   Given I am a mountain
                   And I love chocolate
                   """


        let result = try transformed(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 2)
        XCTAssertTrue(result.scenarios.first?.steps.count == 3)
        XCTAssertTrue(result.scenarios[1].steps.count == 2)
    }

    func testParsingFeatureFileWithDescription() throws {
        let text = """
                   Feature: Minimal Scenario Outline
                   This is a description of the feature

                   Scenario: minimalistic
                   Given I am a mountain
                   """


        let result = try transformed(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertEqual(result.description, "This is a description of the feature")

    }

    func testParsingFeatureFileWithMultiLineDescription() throws {
        let text = """
                   Feature: Minimal Scenario Outline
                   This is a description of the feature
                   This is a description of the feature

                   Scenario: minimalistic
                   Given I am a mountain
                   """


        let result = try transformed(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertEqual(result.description, "This is a description of the feature This is a description of the feature")

    }

    func testParsingFeatureFileWithScenarioDescription() throws {
        let text = """
                   Feature: Minimal Scenario Outline

                   Scenario: minimalistic
                   This is a scenario of the feature

                   Given I am a mountain
                   """


        let result = try transformed(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertEqual(result.scenarios[0].description, "This is a scenario of the feature")
    }



    static var allTests = [
        ("testParsingSimpleFeatureFile", testParsingSimpleFeatureFile),
        ("testParsingSimpleFeatureFileWithVariable", testParsingSimpleFeatureFileWithVariable),
        ("testParsingFeatureFileWithMultipleScenarios", testParsingFeatureFileWithMultipleScenarios),
        ("testParsingFeatureFileWithDescription", testParsingFeatureFileWithDescription),
        ("testParsingFeatureFileWithMultiLineDescription", testParsingFeatureFileWithMultiLineDescription),
        ("testParsingFeatureFileWithScenarioDescription", testParsingFeatureFileWithScenarioDescription),

    ]
}
