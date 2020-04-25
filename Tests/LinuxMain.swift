import XCTest

import GherkinTests

var tests = [XCTestCaseEntry]()
tests += GherkinTests.__allTests()

XCTMain(tests)
