//
//  XCTestGeneratorTests.swift
//  GherkinTests
//
//  Created by iainsmith on 29/03/2018.
//

import XCTest
@testable import GherkinCLILib
import Gherkin

class XCTestGeneratorTests: XCTestCase {
    var feature: Feature!

    override func setUp() {
        super.setUp()
        feature = try! Feature(
            """
            Feature: User Registration
            Scenario: Successful Registration
            Given I am on the homepage
            And I don't have an account

            Scenario: Existing Registration
            Given I am on the homepage
            And I have an account
            """)
    }

    func testGeneratingTestCases() throws {
        let test = XCTestGenerator.test(for: feature)
        let expected =  """
                        import XCTest

                        final class UserRegistration: XCTestCase {
                            func testSuccessfulRegistration() {
                                /* Given */ i_am_on_the_homepage()
                                /* And */ i_dont_have_an_account()
                            }

                            func testExistingRegistration() {
                                /* Given */ i_am_on_the_homepage()
                                /* And */ i_have_an_account()
                            }
                        }
                        """
        XCTAssertEqual(test, expected)
    }

    func testGeneratingTestExtensions() throws {
        let result = XCTestGenerator.steps(for: feature)
        let expected =  """
                        func i_am_on_the_homepage() {
                            XCTFail()
                        }

                        func i_dont_have_an_account() {
                            XCTFail()
                        }

                        func i_have_an_account() {
                            XCTFail()
                        }
                        """
        XCTAssertEqual(result, expected)
    }

    func testFileName() throws {
        let result = XCTestGenerator.featureFileName(for: feature)
        XCTAssertEqual(result, "UserRegistrationFeatureTests.swift")
    }
}
