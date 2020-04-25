// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Gherkin",
    products: [
        .library(name: "Gherkin", targets: ["Gherkin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/Consumer.git", .upToNextMinor(from: "0.3.4")),
    ],
    targets: [
        .target(
            name: "Gherkin",
            dependencies: ["Consumer"]),
        .testTarget(
            name: "GherkinTests",
            dependencies: ["Gherkin"]),
    ],
    swiftLanguageVersions: [.v4_2, .version("5")]
)
