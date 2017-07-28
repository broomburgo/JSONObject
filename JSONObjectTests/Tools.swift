import Foundation
import JSONObject
import SwiftCheck

extension JSONObject {
	var isNull: Bool {
		switch self {
		case .null:
			return true
		default:
			return false
		}
	}

	func isBool(_ bool: Bool) -> Bool {
		switch self {
		case .bool(let value):
			return value == bool
		default:
			return false
		}
	}

	func isNumber(_ number: JSONNumber) -> Bool {
		switch self {
		case .number(let value):
			return value.toNSNumber.isEqual(to: number.toNSNumber)
		default:
			return false
		}
	}

	func isString(_ string: String) -> Bool {
		switch self {
		case .string(let value):
			return string == value
		default:
			return false
		}
	}

	func isArray(_ array: [Any]) -> Bool {
		switch self {
		case .array(let values):
			return values.count == array.count
		default:
			return false
		}
	}

	func isDict(_ dict: [String:Any]) -> Bool {
		switch self {
		case .dict(let values):
			return values.count == dict.count
		default:
			return false
		}
	}
}

struct ArbitraryJSONNumber: Arbitrary {

	let get: JSONNumber
	init(value: JSONNumber) {
		self.get = value
	}

	static var arbitrary: Gen<ArbitraryJSONNumber> {
		return Gen.one(of: [Int.arbitrary.map(ArbitraryJSONNumber.init),
		                    UInt.arbitrary.map(ArbitraryJSONNumber.init),
		                    Float.arbitrary.map(ArbitraryJSONNumber.init),
		                    Double.arbitrary.map(ArbitraryJSONNumber.init)])
	}
}

struct Somestruct: Arbitrary {
	let value: String
	init(value: String) {
		self.value = value
	}

	static var arbitrary: Gen<Somestruct> {
		return String.arbitrary.map(Somestruct.init)
	}
}

final class Someclass: Arbitrary {
	let value: String
	init(value: String) {
		self.value = value
	}

	static var arbitrary: Gen<Someclass> {
		return String.arbitrary.map(Someclass.init)
	}
}

struct TrueArbitrary: Arbitrary {

	let get: Any
	init(value: Any) {
		self.get = value
	}

	static var arbitrary: Gen<TrueArbitrary> {
		return Gen.one(of: [Int.arbitrary.map(TrueArbitrary.init),
		                    Somestruct.arbitrary.map(TrueArbitrary.init),
		                    Someclass.arbitrary.map(TrueArbitrary.init)])
	}
}

extension JSONObject: Arbitrary {
	public static var arbitrary: Gen<JSONObject> {
		let null = Gen<JSONObject>.pure(.null)
		let number = ArbitraryJSONNumber.arbitrary.map { JSONObject.number($0.get) }
		let bool = Bool.arbitrary.map(JSONObject.bool)
		let string = String.arbitrary.map(JSONObject.string)
		let array = ArrayOf<Int>.arbitrary
			.map { $0.getArray.map(JSONObject.number) }
			.map(JSONObject.array)
		let dictionary = DictionaryOf<String,Int>.arbitrary
			.map { $0.getDictionary
				.reduce([String:JSONObject]()) { accumulation, tuple in
					var m_accumulation = accumulation
					m_accumulation[tuple.key] = JSONObject.number(tuple.value)
					return m_accumulation
				}
			}
			.map(JSONObject.dict)
		return Gen<JSONObject>.one(of: [null,number,bool,string,array,dictionary])
	}
}