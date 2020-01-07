//
//  Models.swift
//  SwiftGherkin
//
//  Created by iainsmith on 26/03/2018.
//

import Foundation

/// A model that represents a single Gherkin feature file
public struct Feature: Codable {
    public var name: String
    public var textDescription: String?
    public var scenarios: [Scenario]

    public init(name: String, description: String?, scenarios: [Scenario]) {
        self.name = name
        textDescription = description
        self.scenarios = scenarios
    }

    public init(_ string: String) throws {
        guard let result = try gherkin.match(string).transform(_transform) as? Feature else {
            throw GherkinError.standard
        }

        name = result.name
        textDescription = result.textDescription
        scenarios = result.scenarios
    }

    public init(_ data: Data) throws {
        guard let text = String(data: data, encoding: .utf8) else { throw GherkinError.standard }
        try self.init(text)
    }

    public init(_ filePath: String, featurePath: String) throws {
        let url = URL(fileURLWithPath: filePath)
            .deletingLastPathComponent()
            .appendingPathComponent(featurePath, isDirectory: false)
        let fileContent = try String(contentsOfFile: url.path)
        try self.init(fileContent)
    }
}

/// A scenario that is either a Gherkin Scenario: or a Scenario Outline:
///
/// An outline scenario will include examples
public enum Scenario {
    case simple(ScenarioSimple)
    case outline(ScenarioOutline)

    public var name: String {
        switch self {
        case let .outline(scenario):
            return scenario.name
        case let .simple(scenario):
            return scenario.name
        }
    }

    /// The tags if any for this scenario
    public var tags: [Tag]? {
        switch self {
        case let .outline(scenario):
            return scenario.tags
        case let .simple(scenario):
            return scenario.tags
        }
    }

    /// The steps for this scenario
    public var steps: [Step] {
        switch self {
        case let .outline(scenario):
            return scenario.steps
        case let .simple(scenario):
            return scenario.steps
        }
    }

    /// The description (if any) for this scenario
    public var textDescription: String? {
        switch self {
        case let .outline(scenario):
            return scenario.textDescription
        case let .simple(scenario):
            return scenario.textDescription
        }
    }

    /// The examples if any for this scenario
    public var examples: [Example]? {
        switch self {
        case let .outline(scenario):
            return scenario.examples
        case .simple:
            return nil
        }
    }
}

/// A gherkin Scenario: that does not have examples.
public struct ScenarioSimple: Codable {
    public var tags: [Tag]?
    public var name: String
    public var textDescription: String?
    public var steps: [Step]

    public init(name: String, description: String?, steps: [Step], tags: [Tag]? = nil) {
        self.tags = tags
        self.name = name
        textDescription = description
        self.steps = steps
    }
}

/// A gherkin Scenario Outline: with at least one example.
public struct ScenarioOutline: Codable {
    public var tags: [Tag]?
    public var name: String
    public var textDescription: String?
    public var steps: [Step]
    public var examples: [Example]

    public init(name: String, description: String?, steps: [Step], examples: [Example], tags: [Tag]? = nil) {
        self.name = name
        self.tags = tags
        textDescription = description
        self.steps = steps
        self.examples = examples
    }
}

/// An individual gherkin example that may contain multiple variables.
public struct Example: Codable {
    public var values: [String: String]

    public init(values: [String: String]) {
        self.values = values
    }
}

/// A gherkin step. e.g 'Given I am on the homepage`
public struct Step: Codable {
    public var name: StepName
    public var text: String
    public var examples: [Example]?

    public init(name: StepName, text: String, examples: [Example]?) {
        self.name = name
        self.text = text
        self.examples = examples
    }

    public init(name: StepName, text: String) {
        self.init(name: name, text: text, examples: nil)
    }
}

public struct Tag: Codable {
    public let name: String

    public init(_ name: String) {
        self.name = name
    }
}

/// The Step name
public enum StepName: String, Codable {
    case given, when, then, and, but
}

extension Scenario: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let scenario = try container.decode(ScenarioSimple.self)
            self = .simple(scenario)
        } catch {
            let scenario = try container.decode(ScenarioOutline.self)
            self = .outline(scenario)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .simple(scenario):
            try container.encode(scenario)
        case let .outline(scenario):
            try container.encode(scenario)
        }
    }
}
