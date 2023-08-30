# SwiftyJSearch

SwiftyJSearch extends the functionality of SwiftyJSON with JSON search functionality.

1. [SwiftyJSON](#swiftyjson)
2. [Requirements](#requirements)
3. [Integration](#integration)
4. [Usage](#usage)
    - [SwiftyJSON Extensions](#swiftyjson-extensions)
    - [JSONTree](#jsontree)
5. [Metadata](#metadata)

## SwiftyJSON

This package extends the use of SwiftyJSON, a JSON handling package for Swift.

Checkout the project here: [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)

## Requirements

....

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
*For all JSON object usage info, check out [SwiftyJSON Docs](https://github.com/SwiftyJSON/SwiftyJSON#usage) *

#### Tree Format

Large JSON data can be difficult to read, especially when deeply nest. SwiftyJSearch makes reading JSON much easier with the treeFormat variable.

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
                    "brand": "Jeep",
                    "gasoline": true,
                    "model" : [
                        "Cherokee"
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
```

Console Output:

```swift
└── car types
        ├── #
        │   ├── brand
        │   │   └── Chevy
        │   ├── gasoline
        │   │   └── true
        │   └── models
        │           ├── Camaro
        │           ├── Corvette
        │           ├── Silverado
        │           └── Suburban
        └── my own car
            └── #
                ├── brand
                │   └── Jeep
                ├── model
                │       └── Cherokee
                └── gasoline
                    └── true
```

To increase readability, '#' nodes represent dictionaries with more than a single key

*Since JSON Dictionaries are unordered, the order of pairs in the dictionary will vary*

#### Breadth First Search

```swift
let json = JSON(data: jsonDataFromAbove)
let value = json.bfs("Bronco")
```


### JSONTree

...

## Metadata
Author - Sean Erickson
seanericksonpl12@gmail.com
