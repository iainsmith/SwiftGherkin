//
//  GherkinSearchErrorTests.swift
//  GherkinTests
//
//  Created by Frederic FAUQUETTE on 04/02/2020.
//

@testable import Gherkin
import XCTest

class GherkinSearchErrorTests: XCTestCase {
    func testEquatable() {
        XCTAssertTrue(SearchError.badStep == SearchError.badStep)
        XCTAssertTrue(SearchError.notFound == SearchError.notFound)
        XCTAssertTrue(SearchError.invalidRegex(nil) == SearchError.invalidRegex(nil))
    }

    func testNotEquatable() {
        XCTAssertFalse(SearchError.badStep == SearchError.notFound)
        XCTAssertFalse(SearchError.badStep == SearchError.invalidRegex(nil))
        XCTAssertFalse(SearchError.notFound == SearchError.invalidRegex(nil))
    }
}
