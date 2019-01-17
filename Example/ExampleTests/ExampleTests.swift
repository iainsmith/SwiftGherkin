//
//  ExampleTests.swift
//  ExampleTests
//
//  Created by Timotei Palade on 17.01.19.
//

import XCTest
@testable import Example

class ExampleTests: XCTestCase {

    override func setUp() {
        self.loadStepDefinitions()
    }

    func testExample() {
        Runner.runFeature(featureFile: "Features/simple.feature", testCase: self)
    }
}

class Definitions: Definer {
    override func defineSteps() {
        
        step(expression: "that you reveive {int} {word}") { (arguments, tableValues, docString) in
            XCTAssertTrue(arguments?.count == 2)
        }
        
        step(expression: "print {int} {word}") { (arguments, tableValues, docString) in
            XCTAssertTrue(arguments?.count == 2)
        }
    }
}
