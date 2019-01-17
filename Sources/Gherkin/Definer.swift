//
//  Definer.swift
//  CucumberiOSTests
//
//  Created by Timotei Palade on 15.01.19.
//  Copyright © 2019 Timotei Palade. All rights reserved.
//

import XCTest

public typealias ExpressionArgs = [Any]
public typealias StepDefinition = (_ expressionArgs: ExpressionArgs?, _ tableValues: [[String: String]]?, _ docString: String?) -> Void

open class Definer: NSObject {
    
    public private(set) var test: XCTestCase
    
    required public init(test: XCTestCase) {
        self.test = test
    }
    
    open func defineSteps() -> Void { }
    
    open func step(expression: String, _ f: @escaping StepDefinition) {
        //add the expression and the function to the store.
        self.test.add(expression: expression, f: f)
    }
}
