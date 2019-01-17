//
//  XCTestCase+StepDefinitions.swift
//  CucumberiOSTests
//
//  Created by Timotei Palade on 15.01.19.
//  Copyright © 2019 Timotei Palade. All rights reserved.
//

import Foundation
import XCTest

public extension XCTestCase {
    
    fileprivate struct AssociatedKeys {
        static var Container = "AssociatedContainerKey"
    }
    
    //Is there one stepContainer for every test?
    internal var stepContainer: StepDefinitionsContainer {
        get {
            guard let c = objc_getAssociatedObject(self, &AssociatedKeys.Container) else {
                let container = StepDefinitionsContainer()
                objc_setAssociatedObject(self, &AssociatedKeys.Container, container, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                return container
            }
            
            return c as! StepDefinitionsContainer
        }
    }
    
    public func add(expression: String, f: @escaping StepDefinition) {
        precondition(get(expression: expression) == nil, "Step definitions must be unique")
        self.stepContainer.add(expression: expression, f: f)
    }
    
    func get(expression: String) -> (StepDefinition?, ExpressionArgs?)? {
        return self.stepContainer.f(expression: expression)
    }
    
    public func loadStepDefinitions() {
        allSubclassesOf(Definer.self).forEach { subclass in
            subclass.init(test: self).defineSteps()
        }
    }
}

public typealias GherkinExpression = String
public typealias StepExpression = String

public let GherkinKeywords = Set.init(arrayLiteral: "{int}", "{float}", "{word}")

open class StepDefinitionsContainer: NSObject {
    
    var store: [String: StepDefinition] = [:]
    
    //adds a gherkinExpression
    func add(expression: GherkinExpression, f: @escaping StepDefinition) {
        store[expression] = f
    }
    
    //retrieves the stepDef and the arguments for a step expression
    func f(expression: StepExpression) -> (StepDefinition?, ExpressionArgs?)? {
        for gherkinExpression in store.keys {
            let (isMatch, arguments) = match(expression: expression, gherkinExpression: gherkinExpression)
            if isMatch {
                return (store[gherkinExpression], arguments)
            }
        }
        return nil
    }
    
    //WARNING: {string} is not supported yet.
    func match(expression: StepExpression, gherkinExpression: GherkinExpression) -> (Bool, ExpressionArgs?) {
        //assume expression does not have " or ' since {string} is not supported yet..,m.
        
        let exp_c = expression.components(separatedBy: " ")
        let ghe_c = gherkinExpression.components(separatedBy: " ")
        
        if exp_c.count != ghe_c.count {
            return (false, nil)
        }
        
        var arguments = ExpressionArgs()
        var index = 0
        
        for gherkinComponent in ghe_c {
            let expressionComponent = exp_c[index]
            if GherkinKeywords.contains(gherkinComponent) {
                //dealing with special case
                //extract argument
                let (isMatch, argument) = match(expressionComponent: expressionComponent, gherkinComponent: gherkinComponent)
                
                if !isMatch {
                    break
                }
                
                if let a = argument {
                    arguments.append(a)
                }
            }
            else if gherkinComponent != expressionComponent {
                break
            }
            index += 1
        }
        
        if index == ghe_c.count {
            //success
            if arguments.count == 0 {
                return (true, nil)
            }
            else {
                return (true, arguments)
            }
        }
        else {
            //fail
            return (false, nil)
        }
    }
    
    func match(expressionComponent: String, gherkinComponent: String) -> (Bool, Any?) {
        
        if gherkinComponent == "{int}" {
            if let int = Int(expressionComponent) {
                return (true, int)
            }
            return (false, nil)
        }
        else if gherkinComponent == "{float}" {
            if let float = Float(expressionComponent) {
                return (true, float)
            }
        }
        else if gherkinComponent == "{word}" {
            return (expressionComponent.components(separatedBy: " ").count == 1, expressionComponent)
        }
        
        return (false, nil)

    }
}
