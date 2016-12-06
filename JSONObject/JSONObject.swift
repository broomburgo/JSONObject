import Foundation
import Functional

public protocol JSONNumber {
	var toNSNumber: NSNumber { get }
}

extension Int: JSONNumber {
	public var toNSNumber: NSNumber {
		return NSNumber(value: self)
	}
}

extension UInt: JSONNumber {
	public var toNSNumber: NSNumber {
		return NSNumber(value: self)
	}
}

extension Float: JSONNumber {
	public var toNSNumber: NSNumber {
		return NSNumber(value: self)
	}
}

extension Double: JSONNumber {
	public var toNSNumber: NSNumber {
		return NSNumber(value: self)
	}
}

extension NSNumber: JSONNumber {
	public var toNSNumber: NSNumber {
		return self
	}
}

public enum JSONObject {
	case null
	case number(JSONNumber)
	case bool(Bool)
	case string(String)
	case array([JSONObject])
	case dictionary([String:JSONObject])

	public static func with(_ object: Any?) -> JSONObject {
		switch object {
		case .none:
			return .null
		case .some(let value):
			return with(value)
		}
	}

	public static func with(_ object: Any) -> JSONObject {
		switch object {
		case is NSNull:
			return .null
		case is Int:
			return .number(object as! JSONNumber)
		case is UInt:
			return .number(object as! JSONNumber)
		case is Float:
			return .number(object as! JSONNumber)
		case is Double:
			return .number(object as! JSONNumber)
		case is Bool:
			return .bool(object as! Bool)
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

	public var get: Any {
		switch self {
		case .null:
			return NSNull()
		case .number(let value):
			return value.toNSNumber
		case .bool(let value):
			return NSNumber(value: value)
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

	public var getTopLevel: Any {
		switch self {
		case .null:
			return NSArray(array: [])
		case .number, .bool, .string:
			return NSArray(array: [get])
		case .array, .dictionary:
			return get
		}
	}
}

extension JSONObject: Equatable {
	public static func == (left: JSONObject, right: JSONObject) -> Bool {
		switch (left, right) {
		case (.null, .null):
			return true
		case (.number(let leftValue), .number(let rightValue)):
			return leftValue.toNSNumber.isEqual(to: rightValue.toNSNumber)
		case (.bool(let leftValue), .bool(let rightValue)):
			return leftValue == rightValue
		case (.string(let leftValue), .string(let rightValue)):
			return leftValue == rightValue
		case (.array(let objects1),.array(let objects2)):
			return objects1.isEqual(to: objects2)
		case (.dictionary(let objects1),.dictionary(let objects2)):
			return objects1.isEqual(to: objects2)
		default:
			return false
		}
	}
}

extension JSONObject: Monoid {
	public static var empty: JSONObject {
		return .null
	}

	public func compose(_ other: JSONObject) -> JSONObject {
		switch (self,other) {
		case (.null,_):
			return other
		case (_,.null):
			return self
		case (.array(let objects1),.array(let objects2)):
			return .array(objects1.compose(objects2))
		case (.dictionary(let objects1),.dictionary(let objects2)):
			return .dictionary(objects1.compose(objects2))
		case (.dictionary,_):
			return self
		case (_,.dictionary):
			return other
		case (.array(let objects),_):
			return .array(objects.compose([other]))
		case (_,.array(let objects)):
			return .array([self].compose(objects))
		default:
			return .array([self,other])
		}
	}
}

extension JSONSerialization {
	public static func data(with object: JSONObject) throws -> Data {
		let topLevelObject = object.getTopLevel
		guard JSONSerialization.isValidJSONObject(topLevelObject) else {
			throw NSError(
				domain: "JSONSerialization",
				code: 0,
				userInfo: [NSLocalizedDescriptionKey : "Invalid JSON object",
				           "OriginalJSONObject" : object,
				           "GotTopLevelObject" : topLevelObject])
		}
		return try JSONSerialization.data(withJSONObject: topLevelObject)
	}
}
