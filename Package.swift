// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyJSearch",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        .library(
            name: "SwiftyJSearch",
            targets: ["SwiftyJSearch"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "SwiftyJSearch",
            dependencies: ["SwiftyJSON"],
            path: "Sources"),
        .testTarget(
            name: "SwiftyJSearchTests",
            dependencies: ["SwiftyJSearch"],
            path: "Tests",
            resources: [.copy("SwiftyJSearchTests/JSON/Test1.json")])
    ],
    swiftLanguageVersions: [.v5]
)
