//
//  Keywords.swift
//  Gherkin
//
//  Created by Frederic FAUQUETTE on 22/01/2020.
//

import Foundation

extension String {
    // inspired by: https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift

    /// get the firstmatch for the pattern (pattern will be evaluate as a regex
    /// return nil if no match is found or if the regex if not valid
    /// - Parameter regex: the regex to be evaluated
    func firstMatch(_ regex: NSRegularExpression) -> NSTextCheckingResult? {
        let range = NSRange(location: 0, length: utf16.count)
        return regex.firstMatch(in: self, options: [], range: range)
    }

    /// add the right thing to make the regex fit with exactly the pattern (so user is not forced to add them in the pattern)
    var exactMatch: String {
        "^\(self)$"
    }
}

extension Feature {
    public func scenario(for name: String) throws -> Scenario? {
        let regex = try NSRegularExpression(pattern: name.exactMatch, options: .caseInsensitive)
        return scenarios.first { $0.name.firstMatch(regex) != nil }
    }
}

extension Scenario {
    /// find a step in a scenario
    /// return nil if not match is found or if the regex is not valid
    /// - parameters:
    ///  - text: the regex that needs to be found ( we automatically add `^\(text)$` to get an exact match
    ///  - stepName: the name of the searched step
    /// - Returns: an optional array of steps
    /// - Throws: an error if the regex is incorrect
    public func steps(for text: String, _ stepName: StepName) throws -> [Step]? {
        let regex = try NSRegularExpression(pattern: text.exactMatch, options: .caseInsensitive)
        let results = steps.filter { $0.text.firstMatch(regex) != nil && $0.name == stepName }
        return results.isEmpty ? nil : results
    }
}
