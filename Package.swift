// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyJSearch",
    platforms: [.iOS(.v13), .macOS(.v10_13)],
    products: [
        .library(
            name: "SwiftyJSearch",
            targets: ["SwiftyJSearch"]),
    ],
    targets: [
        .target(
            name: "SwiftyJSearch",
            path: "Sources"),
        .testTarget(
            name: "SwiftyJSearchTests",
            dependencies: ["SwiftyJSearch"],
            path: "Tests",
            resources: [.copy("SwiftyJSearchTests/JSON/Test1.json")])
    ],
    swiftLanguageVersions: [.v5]
)
