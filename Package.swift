// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Gherkin",
    products: [
        .library(
            name: "Gherkin",
            targets: ["Gherkin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/iainsmith/Consumer.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "Gherkin",
            dependencies: ["Consumer"]),
        .testTarget(
            name: "GherkinTests",
            dependencies: ["Gherkin"]),
    ]
)
