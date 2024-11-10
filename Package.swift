// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GherkinQuickParser",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GherkinQuickParser",
            targets: ["GherkinQuickParser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick", .upToNextMajor(from: "7.6.2")),
        .package(url: "https://github.com/Quick/Nimble", .upToNextMajor(from: "13.6.2")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GherkinQuickParser",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "GherkinQuickParserTests",
            dependencies: [
                "GherkinQuickParser",
                "Quick",
                "Nimble"
            ]
        ),
    ]
)
