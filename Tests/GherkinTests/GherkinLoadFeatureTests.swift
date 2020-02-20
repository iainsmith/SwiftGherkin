import Consumer
import Gherkin
import XCTest

class GherkinLoadFeatureTests: XCTestCase {
    func testLoadShouldSucceed() {
        let feature = try? Feature(#file, featurePath: "features/MyTest.feature")
        XCTAssertNotNil(feature)
    }

    func testLoadShouldFailWhenFeaturePathIsNotCorrect() {
        XCTAssertThrowsError(try Feature(#file, featurePath: "features/false.feature")) { error in
            XCTAssertNotNil(error)
        }
    }
}
