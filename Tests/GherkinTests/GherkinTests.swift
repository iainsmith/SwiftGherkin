import Consumer
import Gherkin
import XCTest

final class SwiftGherkinTests: XCTestCase {
    func testParsingSimpleFeatureFile() throws {
        let text = """
        Feature: Minimal Scenario Outline

        Scenario: minimalistic
        Given I am a mountain
        And I love chocolate
        """

        let result = try Feature(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertTrue(result.scenarios.first?.steps.count == 2)
        XCTAssertTrue(result.scenarios.first?.steps[0].text == "I am a mountain")
        XCTAssertEqual(result.scenarios[0].name, "minimalistic")
    }

    func testParsingSimpleFeatureFileWithTag() throws {
        let text = """
        Feature: Minimal Scenario Outline
        
        @testTag
        Scenario: minimalistic
        Given I am a mountain
        And I love chocolate
        """

        let result = try Feature(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertTrue(result.scenarios.first?.steps.count == 2)
        XCTAssertTrue(result.scenarios.first?.steps[0].text == "I am a mountain")
        XCTAssertEqual(result.scenarios[0].name, "minimalistic")
        XCTAssertEqual(result.scenarios[0].tags[0].tagName, "testTag")
    }

    func testParsingSimpleFeatureFileWithMultipleTags() throws {
        let text = """
        Feature: Minimal Scenario Outline
        
        @testTag @testTag2
        Scenario: minimalistic
        Given I am a mountain
        And I love chocolate
        """

        let result = try Feature(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertTrue(result.scenarios.first?.steps.count == 2)
        XCTAssertTrue(result.scenarios.first?.steps[0].text == "I am a mountain")
        XCTAssertEqual(result.scenarios[0].name, "minimalistic")
        XCTAssertEqual(result.scenarios[0].tags.map { $0.tagName }, ["testTag", "testTag2"])
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

        let result = try Feature(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 2)
        XCTAssertTrue(result.scenarios.first?.steps.count == 3)
        XCTAssertTrue(result.scenarios[1].steps.count == 2)
    }

    func testParsingFeatureFileWithDescription() throws {
        let text = """
        Feature: Registration
        Users may want to register to save lists

        Scenario: Successful registration
        Given I am on the home screen
        """

        let result = try Feature(text)
        XCTAssertEqual(result.name, "Registration")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertEqual(result.textDescription, "Users may want to register to save lists")
    }

    func testParsingFeatureFileWithMultiLineDescription() throws {
        let text = """
        Feature: Minimal Scenario Outline
        This is a description of the feature
        This is a description of the feature

        Scenario: minimalistic
        Given I am a mountain
        """

        let result = try Feature(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertEqual(result.textDescription, "This is a description of the feature This is a description of the feature")
    }

    func testParsingFeatureFileWithScenarioDescription() throws {
        let text = """
        Feature: Minimal Scenario Outline

        Scenario: minimalistic
        This is a scenario of the feature

        Given I am a mountain
        """

        let result = try Feature(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertEqual(result.scenarios[0].textDescription, "This is a scenario of the feature")
    }

    func testParsingSimpleFeatureFileWithVariable() throws {
        let text = """
        Feature: Minimal Scenario Outline

        Scenario Outline: minimalistic
        Given I am a <mountain>
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
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertTrue(result.scenarios.first?.steps.count == 2)
        XCTAssertEqual(result.scenarios[0].steps[0].text, "I am a <mountain>")
        XCTAssertEqual(result.scenarios[0].examples!.count, 5)
        XCTAssertEqual(result.scenarios[0].examples![0].values, ["mountain": "etna"])

        let json = try JSONEncoder().encode(result)
        XCTAssertNotNil(json)
    }

    func testParsingSimpleFeatureFileWithMultipleVariable() throws {
        let text = """
        Feature: Minimal Scenario Outline

        Scenario Outline: minimalistic
        Given I am a <mountain>
        And I love <chocolate>

        Examples:
        | mountain | chocolate |
        | etna | cadburys |
        | peak | galaxy |
        """

        let result = try Feature(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertTrue(result.scenarios.first?.steps.count == 2)
        XCTAssertEqual(result.scenarios[0].examples!.count, 2)
        XCTAssertEqual(result.scenarios[0].examples![0].values, ["mountain": "etna", "chocolate": "cadburys"])
        XCTAssertEqual(result.scenarios[0].examples![1].values, ["mountain": "peak", "chocolate": "galaxy"])
    }

    func testParsingSimpleFeatureFileWithMultipleVariableAndTag() throws {
        let text = """
        Feature: Minimal Scenario Outline

        @testTag
        Scenario Outline: minimalistic
        Given I am a <mountain>
        And I love <chocolate>

        Examples:
        | mountain | chocolate |
        | etna | cadburys |
        | peak | galaxy |
        """

        let result = try Feature(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertTrue(result.scenarios.first?.steps.count == 2)
        XCTAssertEqual(result.scenarios[0].examples!.count, 2)
        XCTAssertEqual(result.scenarios[0].examples![0].values, ["mountain": "etna", "chocolate": "cadburys"])
        XCTAssertEqual(result.scenarios[0].examples![1].values, ["mountain": "peak", "chocolate": "galaxy"])
        XCTAssertEqual(result.scenarios[0].tags[0].tagName, "testTag")
    }

    func testParsingSimpleFeatureFileWithMultipleVariableAndTags() throws {
        let text = """
        Feature: Minimal Scenario Outline

        @testTag @testTag2 @testTag3
        Scenario Outline: minimalistic
        Given I am a <mountain>
        And I love <chocolate>

        Examples:
        | mountain | chocolate |
        | etna | cadburys |
        | peak | galaxy |
        """

        let result = try Feature(text)
        XCTAssertEqual(result.name, "Minimal Scenario Outline")
        XCTAssertTrue(result.scenarios.count == 1)
        XCTAssertTrue(result.scenarios.first?.steps.count == 2)
        XCTAssertEqual(result.scenarios[0].examples!.count, 2)
        XCTAssertEqual(result.scenarios[0].examples![0].values, ["mountain": "etna", "chocolate": "cadburys"])
        XCTAssertEqual(result.scenarios[0].examples![1].values, ["mountain": "peak", "chocolate": "galaxy"])
        XCTAssertEqual(result.scenarios[0].tags.map { $0.tagName }, ["testTag", "testTag2", "testTag3"])
    }

    func testCreatingAFeatureInCode() {
        let feature = Feature(name: "Registration",
                              description: nil,
                              scenarios: [
                                  Scenario
                                      .simple(ScenarioSimple(name: "Successful email registration",
                                                             description: "",
                                                             steps: [
                                                                 Step(name: .given, text: "I am on the homepsage"),
                                                                 Step(name: .when, text: "I tap register"),
                                                                 Step(name: .and, text: "I enter valid registration details"),
                                                                 Step(name: .then, text: "I am shown the registration confirmation screen"),
                                      ])),

        ])

        XCTAssertNotNil(feature)
    }

    static var allTests = [
        ("testParsingSimpleFeatureFile", testParsingSimpleFeatureFile),
        ("testParsingSimpleFeatureFileWithTag", testParsingSimpleFeatureFileWithTag),
        ("testParsingSimpleFeatureFileWithMultipleTags", testParsingSimpleFeatureFileWithMultipleTags),
        ("testParsingSimpleFeatureFileWithVariable", testParsingSimpleFeatureFileWithVariable),
        ("testParsingFeatureFileWithMultipleScenarios", testParsingFeatureFileWithMultipleScenarios),
        ("testParsingFeatureFileWithDescription", testParsingFeatureFileWithDescription),
        ("testParsingFeatureFileWithMultiLineDescription", testParsingFeatureFileWithMultiLineDescription),
        ("testParsingFeatureFileWithScenarioDescription", testParsingFeatureFileWithScenarioDescription),
        ("testParsingSimpleFeatureFileWithVariable", testParsingSimpleFeatureFileWithVariable),
        ("testParsingSimpleFeatureFileWithMultipleVariable", testParsingSimpleFeatureFileWithMultipleVariable),
        ("testParsingSimpleFeatureFileWithMultipleVariableAndTag", testParsingSimpleFeatureFileWithMultipleVariableAndTag),
        ("testParsingSimpleFeatureFileWithMultipleVariableAndTags", testParsingSimpleFeatureFileWithMultipleVariableAndTags)
    ]
}
