//
//  Transform.swift
//  SwiftGherkin
//
//  Created by iainsmith on 26/03/2018.
//

import Consumer
import Foundation

func _transform(label: GherkinLabel, values: [Any]) -> Any? {
    switch label {
    case .feature:
        let strings: [String] = filterd(values, is: String.self)!
        guard let name = strings.first else { return nil }
        var description: String? = values.safely(1) as? String ?? nil
        description?.trimWhitespace()
        let scenarios: [Scenario] = filterd(values, is: Scenario.self)!
        let tags: [Tag]? = filterd(values, is: Tag.self)
        let feature = Feature(name: name, description: description, scenarios: scenarios, tags: tags)
        return feature
    case .step:
        let name = StepName(rawValue: (values[0] as! String).lowercased())!
        let text = values[1] as! String
        return Step(name: name, text: text)
    case .scenario:
        let strings: [String] = filterd(values, is: String.self)!
        let name = strings[0]
        var description: String? = strings.safely(1) ?? nil
        description?.trimWhitespace()
        let steps: [Step] = filterd(values, is: Step.self)!
        let tags: [Tag]? = filterd(values, is: Tag.self)
        return Scenario.simple(ScenarioSimple(name: name, description: description, steps: steps, tags: tags))
    case .scenarioOutline:
        let strings: [String] = filterd(values, is: String.self)!
        let name = strings[0]
        var description: String? = strings.safely(1) ?? nil
        description?.trimWhitespace()
        let steps: [Step] = filterd(values, is: Step.self)!
        let tags: [Tag]? = filterd(values, is: Tag.self)
        let examples = values.last as! [Example]
        return Scenario.outline(ScenarioOutline(name: name, description: description, steps: steps, examples: examples, tags: tags))
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
    case .tag:
        return Tag((values[0] as! String).trimmedWhitespace())
    }
}

extension String {
    mutating func trimWhitespace() {
        self = trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func trimmedWhitespace() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private func filterd<T, E>(_ values: [Any], is filteredType: E.Type) -> [T]? {
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
            return Array(self[current ..< end])
        }
    }
}
