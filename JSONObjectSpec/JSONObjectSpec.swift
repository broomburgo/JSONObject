import XCTest
import SwiftCheck
@testable import JSONObject

class JSONObjectSpec: XCTestCase {

	func testCreation() {
		XCTAssertTrue(NSNull().isEqual(JSONObject.null.get))
	}

}
