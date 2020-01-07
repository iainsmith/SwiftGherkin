//
//  Then.swift
//  Gherkin
//
//  Created by Frederic FAUQUETTE on 22/01/2020.
//

import Foundation

/// Find a Then in a scenario
///  ~~~
///  let feature = try Feature(#file, featurePath: "/features/MyTest.feature")
///  guard let scenario = feature.scenario(for: "Successful Name") else {
///      XCTFail("no scenario")
///      return
///  }
///  Then(scenario, "I want to display the current the name") { _ in
///      // Do something
///  }
///  ~~~
/// - Parameters:
///   - scenario: the scenario that contains the searched step
///   - string: the regex to describe the step (we add ^ and $ at the beginning and end of every regex and it is case insensitive)
///   - completion: the completion that will be executed at the end of the search with a `Result<SearchResult, SearchError>`
public func Then(_ scenario: Scenario, _ string: String, _ completion: GherkinRegexCompletion) {
    search(scenario, string, .then, completion)
}
