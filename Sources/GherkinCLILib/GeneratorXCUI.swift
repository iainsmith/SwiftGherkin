//
//  GherkinXCTest.swift
//  GherkinCLI
//
//  Created by iainsmith on 29/03/2018.
//

import Gherkin
import Foundation

public enum XCTestGenerator {
    public static func fileName(for feature: Feature) -> String {
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

    public static func steps(for feature: Feature) -> String {
        let steps = feature.scenarios.flatMap { $0.steps.map { stepFunction(for: $0 )} }
        let unique = Array(Set(steps)).sorted()
        return unique.joined(separator: "\n\n")
    }
}


func tests(for scenarios: [Scenario]) -> String {
    let strings = scenarios.map { test(for:$0) }
    return strings.joined(separator: "\n\n")
}

func stepFunction(for step: Step) -> String {
    return  """
            func \(stepNameAsFunction(step))() {
                XCTFail()
            }
            """
}

func test(for scenario: Scenario) -> String {
    return  """
            func test\(scenario.name.methodName)() {
            \(steps(for: scenario.steps).padEachLine(4))
            }
            """.padEachLine(4)
}

func steps(for steps: [Step]) -> String {
    let steps: [String] = steps.map { step in
        return "/* \(step.name.rawValue.capitalized) */ \(stepNameAsFunction(step))()"
    }

    return steps.joined(separator: "\n")
}


func stepNameAsFunction(_ step: Step) -> String {
    return step.text.normalized.underscored
}


extension String {
    var className: String {
        return self.capitalized.replacingOccurrences(of: " ", with: "")
    }

    var methodName: String {
        let intermediate = self.lowercased().capitalized
        return intermediate.components(separatedBy: " ").joined()
    }

    var normalized: String {
        var validCharacters = CharacterSet.alphanumerics
        validCharacters.insert(" ")
        let valid = self.unicodeScalars.filter { validCharacters.contains($0) }
        return String(valid)
    }

    var underscored: String {
        return self.lowercased().components(separatedBy: " ").joined(separator: "_")
    }

    func padEachLine(_ spaces: Int) -> String {
        return self.components(separatedBy: "\n").map { $0.padded(spaces) }.joined(separator: "\n")
    }

    func padded(_ spaces: Int) -> String {
        let padding = (1...spaces).map({ _ in return " " }).joined()
        return padding + self
    }
}
