# JSONObject

`JSONSerialization` tries to convert an `Any` into valid JSON data, but it might throw an error or even an exception if the `Any` object doesn't actually pass the `isValidJSONObject` check (for example, if it's a dictionary with optional values inside).

The `JSONObject` enum can help creating a valid `Any` with a little more type-safety.

Here's an example of `JSONObject` usage:

```swift
let dict: [String:Any] = [
	"key1" : 3,
	"key2" : "hi",
	"key3" : [
		["key" : 10],
		["key" : 11],
		["key" : 12]
	],
	"key4" : [
		true,
		false,
		false,
		true
	],
	"key5" : true,
	"key6" : NSNull(),
	"key7" : [
		"key1" : false,
		"key2" : [
			1,
			3.14,
			4.00000001
		],
		"key3" : "riciao"
	]
]

let jObj1 = JSONObject.with(dict)

let jObj1Created: JSONObject = .dictionary([
	"key1" : .number(3),
	"key2" : .string("hi"),
	"key3" : .array([
		.dictionary(["key" : .number(10)]),
		.dictionary(["key" : .number(11)]),
		.dictionary(["key" : .number(12)])
		]),
	"key4" : .array([
		.bool(true),
		.bool(false),
		.bool(false),
		.bool(true)
		]),
	"key5" : .bool(true),
	"key6" : .null,
	"key7" : .dictionary([
		"key1" : .bool(false),
		"key2" : .array([
			.number(1),
			.number(3.14),
			.number(4.00000001)
			]),
		"key3" : .string("riciao")
		])
	])


let dictAgain = jObj1.get as! [String:Any]
let dictAgainCreated = jObj1Created.get as! [String:Any]

extension Dictionary {
	func isEqual(to other: Dictionary) -> Bool {
		let first = self as NSDictionary
		let second = other as NSDictionary
		return first.isEqual(second)
	}
}

assert(dict.isEqual(to: dictAgain))
assert(dict.isEqual(to: dictAgainCreated))
assert(dictAgain.isEqual(to: dictAgainCreated))


let array: [Any] = [
	"value1",
	2,
	[
		1,
		"value2"
	],
	true,
	[
		"key1" : 1,
		"key2" : NSNull()
	],
	"value2"
]

let jObj2 = JSONObject.with(array)

let jObj2Created: JSONObject = .array([
	.string("value1"),
	.number(2),
	.array([
		.number(1),
		.string("value2")
		]),
	.bool(true),
	.dictionary([
		"key1" : .number(1),
		"key2" : .null
		]),
	.string("value2")
	])

extension Array {
	func isEqual(to other: Array) -> Bool {
		let first = self as NSArray
		let second = other as NSArray
		return first.isEqual(second)
	}
}

/// this is becuase `jObj2.get as! [Any]` throws an exception (weird)
let _arrayAgain = jObj2.get as? [Any]
let arrayAgain = _arrayAgain!

let _arrayAgainCreated = jObj2Created.get as? [Any]
let arrayAgainCreated = _arrayAgainCreated!

assert(array.isEqual(to: arrayAgain))
assert(array.isEqual(to: arrayAgainCreated))
assert(arrayAgain.isEqual(to: arrayAgainCreated))
```

Please don't use this as a lazy drop-in library: study the logic and consider writing your own abstraction.
