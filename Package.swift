// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Gherkin",
    products: [
        .executable(name: "GherkinCLI", targets: ["GherkinCLI"]),
        .library(name: "Gherkin", targets: ["Gherkin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/Consumer.git", .upToNextMinor(from: "0.3.3")),
        .package(url: "https://github.com/JohnSundell/Files", from: "2.1.0"),
        .package(url: "https://github.com/kylef/Commander", from: "0.8.0"),
    ],
    targets: [
        .target(
            name: "GherkinCLI",
            dependencies: ["GherkinCLILib"]),
        .target(
            name: "GherkinCLILib",
            dependencies: ["Gherkin", "Files", "Commander"]),
        .target(
            name: "Gherkin",
            dependencies: ["Consumer"]),
        .testTarget(
            name: "GherkinTests",
            dependencies: ["GherkinCLILib"]),
    ]
)
