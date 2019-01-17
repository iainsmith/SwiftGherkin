//
//  Runner.swift
//  CucumberiOSTests
//
//  Created by Timotei Palade on 15.01.19.
//  Copyright © 2019 Timotei Palade. All rights reserved.
//

import Foundation
import XCTest

//Gives us the ability to run features or scenarios directly by specifying file and name
open class Runner {
    
    public class func runFeature(featureFile: String, testCase: XCTestCase) {
        
        guard let path = Bundle(for: type(of: testCase)).resourceURL?.appendingPathComponent(featureFile) else {
            preconditionFailure("Path is not valid")
        }
        
        do {
            var text = try String(contentsOf: path)
            //Remove comments
            text = removeComments(text: text)
            
            do {
                let feature = try Feature(text)
                XCTContext.runActivity(named: "Feature: \(feature.name)") { _ in
                    let scenarios = feature.scenarios
                    
                    XCTAssert(!scenarios.isEmpty, "No scenarios found")
                    
                    for scenario in scenarios {
                        if let _ = scenario.examples {
                            executeScenarioOutline(feature: feature, scenario: scenario, testCase: testCase)
                        }
                        else {
                            executeSimpleScenario(feature: feature, scenario: scenario, testCase: testCase)
                        }
                    }
                }
            }
            catch (let e) {
                print(e)
                 XCTFail("Runner.swift - Error parsing feature file.\n Error: \(e.localizedDescription)")
            }
        }
        catch (let e) {
            print(e)
            XCTFail("Runner.swift - The feature file could not be loaded.\n Error: \(e.localizedDescription)")
        }
    }
    
    private class func removeComments(text: String) -> String {
        var newText = text
        while let index = newText.firstIndex(of: "#") {
            //look for new line
            if let newLineIndex = newText[index..<newText.endIndex].firstIndex(of: "\n") {
                newText.replaceSubrange(index...newLineIndex, with: "")
            }
            else {
                //if no new line is found
                newText.replaceSubrange(index..<newText.endIndex, with: "")
            }
        }
        return newText
    }
    
    private class func executeBackground(feature: Feature, testCase: XCTestCase) {
        if let bg = feature.background {
            XCTContext.runActivity(named: "Background:", block: { _ in
                for step in bg.steps {
                    executeStep(step: step, testCase: testCase)
                }
            })
        }
    }
    
    private class func executeSimpleScenario(feature: Feature, scenario: Scenario, testCase: XCTestCase) {
        //execute bg first
        executeBackground(feature: feature, testCase: testCase)
        XCTContext.runActivity(named: "Scenario: \(scenario.name)") { _ in
            for step in scenario.steps {
                executeStep(step: step, testCase: testCase)
            }
        }
    }
    
    private class func executeScenarioOutline(feature: Feature, scenario: Scenario, testCase: XCTestCase) {
        
        let examples = scenario.examples!
        
        for example in examples {
            //execute bg first
            executeBackground(feature: feature, testCase: testCase)
            XCTContext.runActivity(named: "Scenario: \(scenario.name)") { _ in
                for step in scenario.steps {
                    //replace the tags in the step definitions
                    executeStep(step: step.replaceTags(example: example), testCase: testCase)
                }
            }
        }
        
        
    }
    
    private class func executeStep(step: Step, testCase: XCTestCase) {
        let st = step.text
        if let (stepDef, expressionArgs) = testCase.get(expression: st), let def = stepDef {
            //then execute the definition
            XCTContext.runActivity(named: "\(step.name.rawValue.uppercased()) \(step.text)") { (_) in
                def(expressionArgs, step.tableValues, step.docString)
            }
        }
        else {
            //stepDef not found
            XCTFail("No definition found for: \"\(step.text)\". Did you run loadStepDefinitions() in the test setup?")
        }
    }
}
