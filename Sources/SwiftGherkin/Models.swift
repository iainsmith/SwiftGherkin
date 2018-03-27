//
//  Models.swift
//  SwiftGherkin
//
//  Created by iainsmith on 26/03/2018.
//

import Foundation

public struct Feature: Codable {
    public var name: String
    public var description: String?
    public var scenarios: [Scenario]
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

    public var description: String? {
        switch self {
        case .outline(let scenario):
            return scenario.description
        case .simple(let scenario):
            return scenario.description
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
    public var description: String?
    public var steps: [Step]
}

public struct ScenarioOutline: Codable {
    public var name: String
    public var description: String?
    public var steps: [Step]
    public var examples: [Example]
}

public struct Example: Codable {
    public var values: [String: String]
}

public struct Step: Codable {
    public var name: StepName
    public var text: String
}

public enum StepName: String, Codable {
    case given, when, then, and, but
}

extension Scenario: Codable {
    enum CodingKeys: CodingKey {
        case outline
        case simple
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let scenario = try container.decode(ScenarioSimple.self, forKey: .simple)
            self = .simple(scenario)
        } catch {
            let scenario = try container.decode(ScenarioOutline.self, forKey: .outline)
            self = .outline(scenario)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .simple(let scenario):
            try container.encode(scenario, forKey: .simple)
        case .outline(let scenario):
            try container.encode(scenario, forKey: .outline)
        }
    }
}
