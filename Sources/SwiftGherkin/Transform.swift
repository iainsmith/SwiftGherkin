//
//  Transform.swift
//  SwiftGherkin
//
//  Created by iainsmith on 26/03/2018.
//

import Foundation
@testable import Consumer

enum TransformError: Error {
    case unknown
}

public func transformed(_ string: String) throws -> Feature {
    guard let result = try gherkin.match(string).transform(_transform) as? Feature else {
        throw TransformError.unknown
    }

    return result
}

func _transform(label: GherkinLabel, values: [Any]) -> Any? {
    switch label {
    case .feature:
        guard let name = values.first as? String else { return nil }
        var description: String? = values.safely(1) as? String ??  nil
        description = description?.trimmingCharacters(in: .whitespacesAndNewlines)
        let scenarios: [Scenario] = filterd(values, not: String.self)!
        let feature = Feature(name: name, description: description, scenarios: scenarios)
        return feature
    case .step:
        let name = StepName(rawValue: (values[0] as! String).lowercased())!
        let text = values[1] as! String
        return Step(name: name, text: text)
    case .scenario:
        let name = values[0] as! String
        var description: String? = values.safely(1) as? String ??  nil
        description = description?.trimmingCharacters(in: .whitespacesAndNewlines)
        let steps: [Step] = filterd(values, not: String.self)!
        return Scenario.simple(ScenarioSimple(name: name, description: description, steps: steps))
    case .scenarioOutline:
        let name = values[0] as! String
        var description: String? = values.safely(1) as? String ??  nil
        description = description?.trimmingCharacters(in: .whitespacesAndNewlines)
        let steps: [Step] = filterd(values, not: String.self)!
        return Scenario.outline(ScenarioOutline(name: name, description: description, steps: steps, examples: [:]))
    case .name:
        return values.first
    case .description:
        return values.first
    }
}

private func filterd<T,E>(_ values: [Any], not: E.Type) -> [T]? {
    guard let result = Array(values.filter { type(of: $0) != not }) as? [T] else { return nil }
    return result
}

extension Array {
    func safely(_ index: Index) -> Element? {
        if index + 1 <= count {
            return self[index]
        }

        return nil
    }
}
