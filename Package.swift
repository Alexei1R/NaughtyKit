// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NaughtyKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "NaughtyKit",
            targets: ["NaughtyKit"])
    ],
    targets: [
        .target(
            name: "NaughtyKit"),

        //FIXME: Add tests
        .testTarget(
            name: "NaughtyKitTests",
            dependencies: ["NaughtyKit"]
        ),
    ]
)
