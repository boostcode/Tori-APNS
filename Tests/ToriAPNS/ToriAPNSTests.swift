import XCTest
@testable import ToriAPNS

class ToriAPNSTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(ToriAPNS().text, "Hello, World!")
    }


    static var allTests : [(String, (ToriAPNSTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
