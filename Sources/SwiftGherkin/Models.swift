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

public struct Scenario {
    var name: String
    var description: String?
    var steps: [Step]
}

public struct Step {
    var name: StepName
    var text: String
}

enum StepName: String {
    case given, when, then, and, but
}
