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
        description?.trimWhitespace()
        let scenarios: [Scenario] = filterd(values, is: Scenario.self)!
        let feature = Feature(name: name, description: description, scenarios: scenarios)
        return feature
    case .step:
        let name = StepName(rawValue: (values[0] as! String).lowercased())!
        let text = values[1] as! String
        return Step(name: name, text: text)
    case .scenario:
        let name = values[0] as! String
        var description: String? = values.safely(1) as? String ??  nil
        description?.trimWhitespace()
        let steps: [Step] = filterd(values, is: Step.self)!
        return Scenario.simple(ScenarioSimple(name: name, description: description, steps: steps))
    case .scenarioOutline:
        let name = values[0] as! String
        var description: String? = values.safely(1) as? String ??  nil
        description?.trimWhitespace()
        let steps: [Step] = filterd(values, is: Step.self)!
        let examples = values.last as! [Example]
        return Scenario.outline(ScenarioOutline(name: name, description: description, steps: steps, examples: examples))
    case .name:
        return values.first
    case .description:
        return values.first
    case .examples:
        let keys = values[0] as! [String]
        let exampleValues = values[1] as! [String]
        let batches = exampleValues.chuncked(by: keys.count)
        let examples: [[String: String]] = batches.map { batch -> [String: String] in
            let keysAndValues = zip(keys, batch)
            return Dictionary(uniqueKeysWithValues: keysAndValues)
        }
        return examples.map { Example(values: $0) }
    case .exampleKeys:
        return (values as! [String]).map { $0.trimmedWhitespace() }
    case .exampleValues:
        return (values as! [String]).map { $0.trimmedWhitespace() }
    }
}

extension String {
    mutating func trimWhitespace() {
        self = self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func trimmedWhitespace() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private func filterd<T,E>(_ values: [Any], is filteredType: E.Type) -> [T]? {
    guard let result = Array(values.filter { type(of: $0) == filteredType }) as? [T] else { return nil }
    return result
}

extension Array {
    func safely(_ index: Index) -> Element? {
        if index + 1 <= count {
            return self[index]
        }

        return nil
    }

    func chuncked(by: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: by).map { current in
            let end = current + by
            return Array(self[current..<end])
        }
    }
}
