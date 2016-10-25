import Foundation

protocol JSONNumber {
	var toNSNumber: NSNumber { get }
}

extension Int: JSONNumber {
	var toNSNumber: NSNumber {
		return NSNumber(value: self)
	}
}

extension Float: JSONNumber {
	var toNSNumber: NSNumber {
		return NSNumber(value: self)
	}
}

extension Double: JSONNumber {
	var toNSNumber: NSNumber {
		return NSNumber(value: self)
	}
}

extension NSNumber {
	static func with(jsonNumber: JSONNumber) -> NSNumber {
		return jsonNumber.toNSNumber
	}
}

enum JSONObject {
	case dictionary([String:JSONObject])
	case array([JSONObject])
	case string(String)
	case number(JSONNumber)
	case bool(Bool)
	case null

	var get: Any {
		switch self {
		case .null:
			return NSNull()
		case .bool(let value):
			return NSNumber(value: value)
		case .number(let value):
			return NSNumber.with(jsonNumber: value)
		case .string(let value):
			return NSString(string: value)
		case .array(let array):
			return NSArray(array: array.map { $0.get })
		case .dictionary(let dictionary):
			return dictionary
				.map { ($0,$1.get) }
				.reduce(NSMutableDictionary()) {
					$0[$1.0] = $1.1
					return $0
				}
				.copy()
		}
	}

	static func with(_ object: Any) -> JSONObject {
		switch object {
		case is NSNull:
			return .null
		case is Bool:
			return .bool(object as! Bool)
		case is JSONNumber:
			return .number(object as! JSONNumber)
		case is String:
			return .string(object as! String)
		case is [Any]:
			return .array((object as! [Any]).map(JSONObject.with))
		case is [String:Any]:
			return .dictionary((object as! [String:Any])
				.map { ($0,JSONObject.with($1)) }
				.reduce([:]) {
					var m_accumulation = $0
					m_accumulation[$1.0] = $1.1
					return m_accumulation
			})
		default:
			return .null
		}
	}
}

extension JSONSerialization {
	func data(with object: JSONObject) throws -> Data {
		let anyObject = object.get
		guard JSONSerialization.isValidJSONObject(anyObject) else {
			throw NSError(
				domain: "JSONSerialization",
				code: 0,
				userInfo: [NSLocalizedDescriptionKey : "Invalid JSON object"])
		}
		return try JSONSerialization.data(withJSONObject: anyObject)
	}
}
