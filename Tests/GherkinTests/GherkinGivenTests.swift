import Consumer
@testable import Gherkin
import XCTest

class GherkinGivenTests: XCTestCase {
    var feature: Feature!
    var scenario: Scenario!

    override func setUp() {
        super.setUp()
        feature = try! Feature(#file, featurePath: "features/MyTest.feature")
        scenario = try! feature.scenario(for: "A Scenario")
    }

    func testGivenMethodShouldExist() {
        let expectation = XCTestExpectation(description: "testGivenMethodShouldExist")
        Given(scenario, "I am a given") { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGivenMethodShouldFindSpecificString() {
        let expectation = XCTestExpectation(description: "testGivenMethodShouldFindSpecificString")
        var searchResult: Result<SearchResult, SearchError>?
        Given(scenario, "I am a given") { tmpResult in
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
            XCTAssertEqual(search.matches?.first, "I am a given")
        case .failure:
            XCTFail("should be success")
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGivenMethodShouldFindSpecificRegex() {
        let expectation = XCTestExpectation(description: "testGivenMethodShouldFindSpecificString")
        var searchResult: Result<SearchResult, SearchError>?
        Given(scenario, "I am a given with value (\\d)") { tmpResult in
            searchResult = tmpResult
            expectation.fulfill()
        }
        guard let result = searchResult else {
            XCTFail("searchResult should not be nil")
            return
        }
        switch result {
        case let .success(search):
            XCTAssertEqual(search.matches?.count, 2)
            XCTAssertEqual(search.matches?.first, "I am a given with value 2")
            XCTAssertEqual(search.matches?.last, "2")
        case .failure:
            XCTFail("should be success")
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGivenMethodShouldFindGivenAndExample() {
        let expectation = XCTestExpectation(description: "testGivenMethodShouldFindGivenAndExample")
        var searchResult: Result<SearchResult, SearchError>?
        Given(scenario, "I am a given with an example") { tmpResult in
            searchResult = tmpResult
            expectation.fulfill()
        }
        guard let result = searchResult else {
            XCTFail("searchResult should not be nil")
            return
        }
        switch result {
        case let .success(search):
            XCTAssertNotNil(search.step.examples)
            XCTAssertEqual(search.step.examples?.count, 1)
            XCTAssertEqual(search.step.examples![0].values, ["test value": "I am a value"])
        case .failure:
            XCTFail("should be success")
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGivenMethodShouldNotFindSpecificString() {
        let expectation = XCTestExpectation(description: "testGivenMethodShouldNotFindSpecificString")
        var searchResult: Result<SearchResult, SearchError>?
        Given(scenario, "I am not in the steps") { tmpResult in
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

    func testGivenMethodShouldNotFindSpecificStepIfNotGiven() {
        let expectation = XCTestExpectation(description: "testGivenMethodShouldNotFindSpecificStepIfNotGiven")
        var searchResult: Result<SearchResult, SearchError>?
        Given(scenario, "I am a when") { tmpResult in
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

    func testGivenMethodShouldNotFindSpecificStepIfNotARegex() {
        let expectation = XCTestExpectation(description: "testGivenMethodShouldNotFindSpecificStepIfNotGiven")
        var searchResult: Result<SearchResult, SearchError>?
        Given(scenario, "I am a bad regex[") { tmpResult in
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
            XCTAssertEqual(error, SearchError.invalidRegex(nil))
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
