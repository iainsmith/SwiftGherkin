//
//  ClILibTests.swift
//  GherkinTests
//
//  Created by iainsmith on 30/03/2018.
//

import XCTest
@testable import GherkinCLILib
import Gherkin
import Files

class BootstrapTests: XCTestCase {
    var featureText: String!

    override func setUp() {
        super.setUp()
        featureText =
        """
        Feature: User Registration
        Scenario: Successful Registration
        Given I am on the homepage
        And I don't have an account

        Scenario: Existing Registration
        Given I am on the homepage
        And I have an account
        """
    }

    func testSyncingAFolder () throws {
        let filesystem = FileSystem()
        let temp = filesystem.temporaryFolder
        let name = "gherkinFeatureTests"

        let folder = try temp.createSubfolderIfNeeded(withName: name)
        let features = try folder.createSubfolderIfNeeded(withName: "Features")
        let tests = try folder.createSubfolderIfNeeded(withName: "Tests")


        try [features, tests].forEach { try $0.empty() }

        _ = try features.createFile(named: "User Registration.feature", contents: featureText)

        let result = try GherkinSync.generateTestCode(fromFeatureFolderPath: features.path,
                                                      toOutputPath: tests.path,
                                                      using: XCTestGenerator.self)
        XCTAssertEqual(result.updated.count, 2)
        XCTAssertEqual(result.failed.count, 0)

        let first = result.updated[0]

        XCTAssertEqual(first.name, "UserRegistrationFeatureTests.swift")

        try folder.delete()
    }
}
