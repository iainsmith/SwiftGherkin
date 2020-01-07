import Consumer
@testable import Gherkin
import XCTest

class GherkinAndTests: XCTestCase {
    var feature: Feature!
    var scenario: Scenario!

    override func setUp() {
        super.setUp()
        feature = try! Feature(#file, featurePath: "features/MyTest.feature")
        scenario = try! feature.scenario(for: "A Scenario")
    }

    func testAndMethodShouldExist() {
        let expectation = XCTestExpectation(description: "testAndMethodShouldExist")
        And(scenario, "I am a and") { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testAndMethodShouldFindSpecificString() {
        let expectation = XCTestExpectation(description: "testAndMethodShouldFindSpecificString")
        var searchResult: Result<SearchResult, SearchError>?
        And(scenario, "I am a and") { tmpResult in
            searchResult = tmpResult
            expectation.fulfill()
        }
        guard let result = searchResult else {
            XCTFail("searchResult should not be nil")
            return
        }
        switch result {
        case let .success(search):
            XCTAssertEqual(search.matches?.count, 1)
            XCTAssertEqual(search.matches?.first, "I am a and")
        case .failure:
            XCTFail("should be success")
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testAndMethodShouldNotFindSpecificString() {
        let expectation = XCTestExpectation(description: "testAndMethodShouldNotFindSpecificString")
        var searchResult: Result<SearchResult, SearchError>?
        And(scenario, "I am not in the steps") { tmpResult in
            searchResult = tmpResult
            expectation.fulfill()
        }
        guard let result = searchResult else {
            XCTFail("searchResult should not be nil")
            return
        }
        switch result {
        case .success:
            XCTFail("should be failure")
        case let .failure(error):
            XCTAssertEqual(error, SearchError.notFound)
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testAndMethodShouldNotFindSpecificStepIfNotAnd() {
        let expectation = XCTestExpectation(description: "testAndMethodShouldNotFindSpecificStepIfNotAnd")
        var searchResult: Result<SearchResult, SearchError>?
        And(scenario, "I am a given") { tmpResult in
            searchResult = tmpResult
            expectation.fulfill()
        }
        guard let result = searchResult else {
            XCTFail("searchResult should not be nil")
            return
        }
        switch result {
        case .success:
            XCTFail("should be failure")
        case let .failure(error):
            XCTAssertEqual(error, SearchError.badStep)
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
