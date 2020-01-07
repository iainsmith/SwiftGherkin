import Consumer
@testable import Gherkin
import XCTest

class GherkinButTests: XCTestCase {
    var feature: Feature!
    var scenario: Scenario!

    override func setUp() {
        super.setUp()
        feature = try! Feature(#file, featurePath: "features/MyTest.feature")
        scenario = try! feature.scenario(for: "A Scenario")
    }

    func testButMethodShouldExist() {
        let expectation = XCTestExpectation(description: "testButMethodShouldExist")
        But(scenario, "I am a but") { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testButMethodShouldFindSpecificString() {
        let expectation = XCTestExpectation(description: "testButMethodShouldFindSpecificString")
        var searchResult: Result<SearchResult, SearchError>?
        But(scenario, "I am a but") { tmpResult in
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
            XCTAssertEqual(search.matches?.first, "I am a but")
        case .failure:
            XCTFail("should be success")
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testButMethodShouldNotFindSpecificString() {
        let expectation = XCTestExpectation(description: "testButMethodShouldNotFindSpecificString")
        var searchResult: Result<SearchResult, SearchError>?
        But(scenario, "I am not in the steps") { tmpResult in
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

    func testButMethodShouldNotFindSpecificStepIfNotBut() {
        let expectation = XCTestExpectation(description: "testButMethodShouldNotFindSpecificStepIfNotBut")
        var searchResult: Result<SearchResult, SearchError>?
        But(scenario, "I am a when") { tmpResult in
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

    static var allTests = [
        ("testButMethodShouldExist", testButMethodShouldExist),
        ("testButMethodShouldFindSpecificString", testButMethodShouldFindSpecificString),
        ("testButMethodShouldNotFindSpecificString", testButMethodShouldNotFindSpecificString),
        ("testButMethodShouldNotFindSpecificStepIfNotBut", testButMethodShouldNotFindSpecificStepIfNotBut),
    ]
}
