//
//  GherkinXCTest.swift
//  GherkinCLI
//
//  Created by iainsmith on 29/03/2018.
//

import Gherkin
import Foundation

public enum XCTestGenerator {
    static let stepFileName = "_GeneratedSteps.swift"

    public static func featureFileName(for feature: Feature) -> String {
        return "\(feature.name.className)FeatureTests.swift"
    }

    public static func test(for feature: Feature) -> String {
        return  """
                import XCTest

                final class \(feature.name.className): XCTestCase {
                \(tests(for: feature.scenarios))
                }
                """
    }

    public static func testStubs(for feature: Feature) -> String {
        let functions = steps(for: feature)
        return  """
                import XCTest

                extension XCTestCase {
                \(functions.padEachLine(4))
                }
                """
    }

    public static func steps(for feature: Feature) -> String {
        let steps = feature.scenarios.flatMap { $0.steps.map { stepFunction(for: $0 )} }
        let unique = Array(Set(steps)).sorted()
        return unique.joined(separator: "\n\n")
    }
}


private func tests(for scenarios: [Scenario]) -> String {
    let strings = scenarios.map { test(for:$0) }
    return strings.joined(separator: "\n\n")
}

private func stepFunction(for step: Step) -> String {
    return  """
            func \(stepNameAsFunction(step))() {
                XCTFail()
            }
            """
}

private func test(for scenario: Scenario) -> String {
    return  """
            func test\(scenario.name.methodName)() {
            \(steps(for: scenario.steps).padEachLine(4))
            }
            """.padEachLine(4)
}

private func steps(for steps: [Step]) -> String {
    let steps: [String] = steps.map { step in
        return "/* \(step.name.rawValue.capitalized) */ \(stepNameAsFunction(step))()"
    }

    return steps.joined(separator: "\n")
}


private func stepNameAsFunction(_ step: Step) -> String {
    return step.text.normalized.underscored
}
