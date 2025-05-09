// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ArkansasRiverWidget",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ArkansasRiverWidget",
            targets: ["ArkansasRiverWidget"]),
    ],
    dependencies: [
        // No external dependencies needed
    ],
    targets: [
        .target(
            name: "ArkansasRiverWidget",
            dependencies: []),
    ]
)
