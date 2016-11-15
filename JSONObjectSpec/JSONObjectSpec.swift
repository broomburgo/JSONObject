import XCTest
import SwiftCheck
@testable import JSONObject

class JSONObjectSpec: XCTestCase {

	func testCreationWithOptional1() {
		property("JSONObject creation with Optional will result in .null if Optional is .none, or other if .some - 1") <- {
			let some: Int? = 42
			let none: Int? = nil

			return (JSONObject.with(some).isNull == false) <?> "With .some"
				^&&^
				(JSONObject.with(none).isNull == true) <?> "With .none"
		}
	}

	func testCreationWithOptional2() {
		property("JSONObject creation with Optional will result in .null if Optional is .none, or other if .some - 1") <- forAll { (opt: OptionalOf<Int>) in
			let optional = opt.getOptional
			return JSONObject.with(optional).isNull == (optional == nil)
		}
	}

	func testCreationWithNSNNull() {
		property("JSONObject creation with NSNull will result in .null") <- {
			return JSONObject.with(NSNull()).isNull == true
		}
	}

	func testCreationWithBool() {
		property("JSONObject creation with Bool will result in .bool") <- {
			return (JSONObject.with(true).isBool(true)) <?> "With true"
				^&&^
				(JSONObject.with(false).isBool(false)) <?> "With false"
		}
	}

	func testCreationWithIntUIntFloatDouble() {
		property("JSONObject creation with Int, UInt, Float, Double will result in .number") <- forAll { (ajn: ArbitraryJSONNumber) in
			let jn = ajn.get
			return JSONObject.with(jn).isNumber(jn)
		}
	}

	func testCreationWithNSNumber() {
		property("JSONObject creation with NSNumber will result in .number") <- forAll { (ajn: ArbitraryJSONNumber) in
			let number = ajn.get.toNSNumber
			return JSONObject.with(number).isNumber(number)
		}
	}

	func testCreationWithString() {
		property("JSONObject creation with String will result in .string") <- forAll { (string: String) in
			return JSONObject.with(string).isString(string)
		}
	}

	func testCreationWithArray() {
		property("JSONObject creation with Array will result in .array") <- forAll { (arrayOf: ArrayOf<TrueArbitrary>) in
			let array = arrayOf.getArray
			return JSONObject.with(array).isArray(array)
		}
	}

	func testCreationWithDictionary() {
		property("JSONObject creation with Dictionary will result in .dictionary") <- forAll { (dictOf: DictionaryOf<String,TrueArbitrary>) in
			let dict: [String:Any] = dictOf.getDictionary
			return JSONObject.with(dict).isDictionary(dict)
		}
	}

	func testGetNull() {
		property("JSONObject.get is consistent .null") <- {
			NSNull().isEqual(JSONObject.null.get)
		}
	}

	func testGetBool() {
		property("JSONObject.get is consistent with bool") <- {
			let isBoolTrue = NSNumber(value: true).isEqual(JSONObject.bool(true).get)
			let isBoolFalse = NSNumber(value: false).isEqual(JSONObject.bool(false).get)
			return isBoolTrue <?> "Is consistent for true"
				^&&^
				isBoolFalse <?> "Is consistent for false"
		}
	}

	func testGetNumber() {
		property("JSONObject.get is consistent number") <- forAll { (ajn: ArbitraryJSONNumber) in
			let number = ajn.get
			return number.toNSNumber.isEqual(JSONObject.number(number).get)
		}
	}

	func testGetString() {
		property("JSONObject.get is consistent with string") <- {
			return NSString(string: "ciao").isEqual(JSONObject.string("ciao").get)
		}
	}

	func testGetArray() {
		property("JSONObject.get is consistent with array") <- {
			return NSArray(array: [1,
			                       "2",
			                       true])
				.isEqual(JSONObject.array([.number(1),
				                           .string("2"),
				                           .bool(true)]).get)
		}
	}

	func testGetDictionary() {
		property("JSONObject.get is consistent with dictionary") <- {

			return NSDictionary(dictionary: ["1":1,
			                                 "2":"2",
			                                 "3":true])
				.isEqual(JSONObject.dictionary(["1":.number(1),
				                                "2":.string("2"),
				                                "3":.bool(true)]).get)
		}
	}

	func testProcessingConsistencyNull() {
		property("JSONObject processing consistency: null") <- {
			return NSNull().isEqual(JSONObject.with(NSNull()).get)
		}
	}

	func testProcessingConsistencyBool() {
		property("JSONObject processing consistency: bool") <- {
			return NSNumber(value: true).isEqual(JSONObject.with(true).get)
			&& NSNumber(value: false).isEqual(JSONObject.with(false).get)
		}
	}

	func testProcessingConsistencyJSONNumber() {
		property("JSONObject processing consistency: number") <- forAll { (ajn: ArbitraryJSONNumber) in
			return ajn.get.toNSNumber.isEqual(JSONObject.with(ajn.get).get)
		}
	}

	func testProcessingConsistencyString() {
		property("JSONObject processing consistency: string") <- forAll { (string: String) in
			return NSString(string: string).isEqual(JSONObject.with(string).get)
		}
	}

	func testProcessingConsistencyArray() {
		property("JSONObject processing consistency: array") <- {
			let array = NSArray(array: [1,"2",true])
			return array.isEqual(JSONObject.with(array).get)
		}
	}

	func testProcessingConsistencyDictionary() {
		property("JSONObject processing consistency: dictionary") <- {
			let dict = NSDictionary(dictionary: ["1":1,"2":"2","3":true])
			return dict.isEqual(JSONObject.with(dict).get)
		}
	}

	func testDataWithNull() {
		property("no error for data with null") <- {
			do {
				try _ = JSONSerialization.data(with: .null)
				return true
			}
			catch {
				return false
			}
		}
	}

	func testDataWithNumber() {
		property("no error for data with number") <- forAll { (ajn: ArbitraryJSONNumber) in
			do {
				try _ = JSONSerialization.data(with: .number(ajn.get))
				return true
			}
			catch {
				return false
			}
		}
	}

	func testDataWithBool() {
		property("no error for data with bool") <- {
			do {
				try _ = JSONSerialization.data(with: .bool(true))
				try _ = JSONSerialization.data(with: .bool(false))
				return true
			}
			catch {
				return false
			}
		}
	}

	func testDataWithString() {
		property("no error for data with string") <- forAll { (string: String) in
			do {
				try _ = JSONSerialization.data(with: .string(string))
				return true
			}
			catch {
				return false
			}
		}
	}

	func testDataWithArray() {
		property("no error for data with array") <- {
			do {
				try _ = JSONSerialization.data(with: .array([.number(1),
				                                             .string("2"),
				                                             .bool(true)]))
				return true
			}
			catch {
				return false
			}
		}
	}

	func testDataWithDictionary() {
		property("no error for data with dictionary") <- {
			do {
				try _ = JSONSerialization.data(with: .dictionary(["1":.number(1),
				                                                  "2":.string("2"),
				                                                  "3":.bool(true)]))
				return true
			}
			catch {
				return false
			}
		}
	}
}
