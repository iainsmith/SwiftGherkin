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
        self.textDescription = description
        self.scenarios = scenarios
    }
}

public enum Scenario {
    case simple(ScenarioSimple)
    case outline(ScenarioOutline)

    public var steps: [Step] {
        switch self {
        case .outline(let scenario):
            return scenario.steps
        case .simple(let scenario):
            return scenario.steps
        }
    }

    public var textDescription: String? {
        switch self {
        case .outline(let scenario):
            return scenario.textDescription
        case .simple(let scenario):
            return scenario.textDescription
        }
    }

    public var examples: [Example]? {
        switch self {
        case .outline(let scenario):
            return scenario.examples
        case .simple:
            return nil
        }
    }
}

public struct ScenarioSimple: Codable {
    public var name: String
    public var textDescription: String?
    public var steps: [Step]

    public init(name: String, description: String?, steps: [Step]) {
        self.name = name
        self.textDescription = description
        self.steps = steps
    }
}

public struct ScenarioOutline: Codable {
    public var name: String
    public var textDescription: String?
    public var steps: [Step]
    public var examples: [Example]

    public init(name: String, description: String?, steps: [Step], examples: [Example]) {
        self.name = name
        self.textDescription = description
        self.steps = steps
        self.examples = examples
    }
}

public struct Example: Codable {
    public var values: [String: String]

    public init(values: [String: String]) {
        self.values = values
    }
}

public struct Step: Codable {
    public var name: StepName
    public var text: String

    public init(name: StepName, text: String) {
        self.name = name
        self.text = text
    }
}

public enum StepName: String, Codable {
    case given, when, then, and, but
}

extension Scenario: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()
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
        case .simple(let scenario):
            try container.encode(scenario)
        case .outline(let scenario):
            try container.encode(scenario)
        }
    }
}
