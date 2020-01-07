import Consumer
@testable import Gherkin
import XCTest

class GherkinFeatureTests: XCTestCase {
    var feature: Feature!

    override func setUp() {
        super.setUp()
        feature = try? Feature(#file, featurePath: "features/MyTest.feature")
    }

    func testScenarioShouldExist() {
        XCTAssertNotNil(try! feature.scenario(for: "A Scenario"))
    }

    func testScenarioShouldBeCaseInsensitive() {
        XCTAssertNotNil(try! feature.scenario(for: "a scenArio"))
    }

    func testScenarioShouldNotExist() {
        XCTAssertNil(try! feature.scenario(for: "Not a Scenario"))
    }

    func testScenarioBadRegex() {
        XCTAssertThrowsError(try feature.scenario(for: "[")) { error in
            XCTAssertNotNil(error)
            XCTAssertEqual((error as NSError).code, 2048)
        }
    }

    func testFeatureShouldFailIfScenarioOutlineHasNoExamples() throws {
        let text = """
        Feature: Minimal Scenario Outline

        Scenario Outline: minimalistic
        Given I am a mountain
        And I love chocolate
        And I love chocolate
        """

        XCTAssertThrowsError(try Feature(text)) { error in
            XCTAssertNotNil(error)
            switch (error as? GherkinConsumer.Error)!.kind {
            case let .expected(label):
                XCTAssertTrue(label.description == "examples")
            default:
                XCTFail("nothing to do here")
            }
        }
    }

    static var allTests = [
        ("testScenarioShouldExist", testScenarioShouldExist),
        ("testScenarioShouldBeCaseInsensitive", testScenarioShouldBeCaseInsensitive),
        ("testScenarioShouldNotExist", testScenarioShouldNotExist),
        ("testScenarioBadRegex", testScenarioBadRegex),
        ("testFeatureShouldFailIfScenarioOutlineHasNoExamples", testFeatureShouldFailIfScenarioOutlineHasNoExamples),
    ]
}
