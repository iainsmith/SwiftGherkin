//
//  Models.swift
//  SwiftGherkin
//
//  Created by iainsmith on 26/03/2018.
//

import Foundation

public struct Feature {
    var name: String
    var description: String?
    var scenarios: [Scenario]
}

public struct ScenarioSimple {
    var name: String
    var description: String?
    var steps: [Step]
}

public struct ScenarioOutline {
    var name: String
    var description: String?
    var steps: [Step]
    var examples: [String: String]
}

enum Scenario {
    case simple(ScenarioSimple)
    case outline(ScenarioOutline)

    var steps: [Step] {
        switch self {
        case .outline(let scenario):
            return scenario.steps
        case .simple(let scenario):
            return scenario.steps
        }
    }

    var description: String? {
        switch self {
        case .outline(let scenario):
            return scenario.description
        case .simple(let scenario):
            return scenario.description
        }
    }
}

public struct Step {
    var name: StepName
    var text: String
}

enum StepName: String {
    case given, when, then, and, but
}
