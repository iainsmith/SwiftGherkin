import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(GherkinTests.allTests),
            testCase(GherkinLoadFeatureTests.allTests),
            testCase(GherkinGivenTests.allTests),
            testCase(GherkinFeatureTests.allTests),
            testCase(GherkinScenarioTests.allTests),
            testCase(GherkinWhenTests.allTests),
            testCase(GherkinThenTests.allTests),
            testCase(GherkinAndTests.allTests),
            testCase(GherkinButTests.allTests),
            testCase(GherkinRegexForStepTests.allTests),
        ]
    }
#endif
