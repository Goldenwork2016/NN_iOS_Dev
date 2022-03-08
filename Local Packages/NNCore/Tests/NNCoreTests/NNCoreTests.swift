import XCTest
@testable import NNCore

final class NNCoreTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NNCore().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample)
    ]
}
