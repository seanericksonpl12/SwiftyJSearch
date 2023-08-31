# SwiftyJSearch

SwiftyJSearch extends the functionality of SwiftyJSON with JSON search functionality.

1. [SwiftyJSON](#swiftyjson)
2. [Requirements](#requirements)
3. [Integration](#integration)
4. [Usage](#usage)
    - [SwiftyJSON Extensions](#swiftyjson-extensions)
        * [Tree Format](#tree-format)
        * [Breadth First Search](#breadth-first-search)
    - [JSONTree](#jsontree)
        * [Initialization](#initialization)
        * [Content Types](#content-types)
        * [Pretty Format](#pretty-format)
        * [Search](#search)
        * [Modify](#modify)
5. [Metadata](#metadata)

## SwiftyJSON

This package extends the use of SwiftyJSON, a JSON handling package for Swift.

Checkout the project here: [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)

## Requirements

Previous OS versions and Xcode versions currently untested.
Known working versions:
- iOS 16.0+ | macOS 13.4+
- Xcode 14

## Warning

This package is not finished and currently in development, version will change and current usage will have unknown results.

## Integration

#### Swift Package Manager

You can use [The Swift Package Manager](https://swift.org/package-manager) to install `SwiftyJSearch` by adding the proper description to your `Package.swift` file:

```swift
// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/seanericksonpl12/SwiftyJSearch.git", branch: "main"),
    ]
)
```
Then run `swift build` whenever you get prepared.

## Usage

### SwiftyJSON Extensions

#### SwiftyJSON Initialization

```swift
import SwiftyJSON
import SwiftyJSearch
```

```swift
let json = JSON(data: someData)
```
For all JSON object usage info, check out [SwiftyJSON Docs](https://github.com/SwiftyJSON/SwiftyJSON#usage)

#### Tree Format

Large JSON data can be difficult to read, especially when deeply nested. SwiftyJSearch makes reading JSON much easier with the treeFormat variable.

Example JSON:

```json
[
    {
        "car types": [
            {
                "brand": "Chevy",
                "gasoline": true,
                "models": [
                    "Camaro",
                    "Corvette",
                    "Silverado",
                    "Suburban"
                ]
            },
            {
                "my own car": {
                    "miles": 91242,
                    "gasoline": true,
                    "parts" : [
                        "steering wheel",
                        "brake pads",
                        "chassis"
                    ]
                }
            }
        ]
    }
]
```



```swift
let json = JSON(data: jsonDataFromAbove)
print(json.treeFormat)

// output:

└── car types
        ├── #
        │   ├── models
        │   │       ├── Camaro
        │   │       ├── Corvette
        │   │       ├── Silverado
        │   │       └── Suburban
        │   ├── gasoline
        │   │   └── true
        │   └── brand
        │       └── Chevy
        └── my own car
            └── #
                ├── miles
                │   └── 91242
                ├── gasoline
                │   └── true
                └── parts
                        ├── steering wheel
                        ├── brake pads
                        └── chassis
```

To increase readability, '#' nodes represent dictionaries with more than a single key

*Since JSON Dictionaries are unordered, the order of pairs in the dictionary will vary*

#### Breadth First Search

```swift
let json = JSON(data: jsonDataFromAbove)
let values = json.bfs(for: "my own car")
print(values.first!.treeFormat)

// output:

#
├── parts
│       ├── steering wheel
│       ├── brake pads
│       └── chassis
├── miles
│   └── 91242
└── gasoline
    └── true
```

Or search multiple keys with one search:

```swift
let json = JSON(data: jsonDataFromAbove)
let valueDictionary = json.bfs(for: ["models", "parts"])

if let parts = valueDictionary["parts"]?.first, let models = valueDictionary["models"]?.first {
    print(models.treeFormat)
    print(parts.treeFormat)
}

// output:

├── Camaro
├── Corvette
├── Silverado
└── Suburban

├── steering wheel
├── brake pads
└── chassis
```

### JSONTree

For an alternate way to store and manipulate JSON Data, you can use the JSONTree structure.  JSONTree is a basic tree data structure, but built around storing JSON data.

#### Initialization

```swift
let json = JSON(data: jsonDataFromAbove)
let tree = JSONTree(json: json)
```

Or build it yourself:

```swift
let root = JSONTree.Node(children: [], content: .string("root"))
let tree = JSONTree(root: root)
```

#### Content Types

JSONTree nodes store values with the `ContentType` Enum.

```swift
ContentType values:
    .string(String)
    .number(NSNumber)
    .bool(Bool)
    .null
```

#### Pretty Format

The JSONTree prettyFormat works the same as the JSON treeFormat:

```swift
let json = JSON(data: jsonDataFromAbove)
let tree = JSONTree(json: json)
print(tree.prettyFormat)

// output:

└── car types
        ├── #
        │   ├── models
        │   │       ├── Camaro
        │   │       ├── Corvette
        │   │       ├── Silverado
        │   │       └── Suburban
        │   ├── gasoline
        │   │   └── true
        │   └── brand
        │       └── Chevy
        └── my own car
            └── #
                ├── miles
                │   └── 91242
                ├── gasoline
                │   └── true
                └── parts
                        ├── steering wheel
                        ├── brake pads
                        └── chassis
```

*JSONTree is autobalanced by sorting unordered dictionaries on init to improve search speed, so output between json.treeFormat and tree.prettyFormat may vary*

#### Search

Search for any data in the tree, similar to bfs with json objects, and get a reference to the tree node containing it:

```swift
let json = JSON(data: jsonDataFromAbove)
let tree = JSONTree(json: json)

let node = tree.search(for: "chassis")
node?.content = .string("radio")
print(tree.prettyFormat)

// output:
...
    └── my own car
        └── #
            ├── miles
            │   └── 91242
            ├── gasoline
            │   └── true
            └── parts
                    ├── steering wheel
                    ├── brake pads
                    └── radio
```

#### Modify

Modify the json yourself by adding new children to nodes, or removing nodes with the provided functions:

```swift
let json = JSON(data: jsonDataFromAbove)
let tree = JSONTree(json: json)
tree.removeAll(where: { $0.content == .string("parts") || $0.content == .number(91242)})
print(tree.prettyFormat)

// output:

...
    └── my own car
        └── #
            ├── miles
            ├── gasoline
            │   └── true
            ├── steering wheel
            ├── brake pads
            └── chassis
```

## Metadata
Author - Sean Erickson
seanericksonpl12@gmail.com
