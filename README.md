# JSONObject

`NSJSONSerialization` tries to convert an `Any` into valid JSON data, but it might throw an error or even an exception if the `Any` object doesn't actually pass the `isValidJSONObject` check.

The `JSONObject` enum can help creating a valid `Any` with a little more type-safety.

Here's an example:

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
			3,
			4
		],
		"key3" : "riciao"
	]
]

let jObj1 = JSONObject.with(dict)

let dictAgain = jObj1.get as! [String:Any]

extension Dictionary {
	func isEqual(to other: Dictionary) -> Bool {
		let first = self as NSDictionary
		let second = other as NSDictionary
		return first.isEqual(second)
	}
}

assert(dict.isEqual(to: dictAgain))

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

assert(array.isEqual(to: arrayAgain))
```
Please don't use this as a lazy drop-in: study the logic and consider writing your own abstraction.
