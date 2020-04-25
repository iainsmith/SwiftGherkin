# Gherkin

[![Build Status](https://travis-ci.org/iainsmith/SwiftGherkin.svg?branch=master)](https://travis-ci.org/iainsmith/SwiftGherkin)

A Swift package for working with gherkin based .feature files.

Warning: This package only handles a limited subset of Gherkin. I'd like to improve this. If you would like to help, see the [Gherkin Subset](#Gherkin-Subset) section.

## Usage

You can initialize a `Feature` from a `String` or from some `Data`. These initializers will throw an `Error` if the parser cannot read the content.

```swift
import Gherkin

do {
  let text = """
             Feature: Registration
             Users may want to register to save lists
             
             Scenario: Successful registration
             Given I am on the registration screen
             When I enter <email> into the email field
             And submit the form
             Then I see the registration page

             Examples:
             | email                  |
             | 1@notanemail.com       |
             | 1+gmail@notanemail.com |
             """

  let feature = try Feature(text)
  print(feature.name) // Registration
  let firstScenario = feature.scenarios[0]
  print(firstScenario.steps.count) // 4

  print(firstScenario.examples) // ["1@notanemail.com", "1+gmail@notanemail.com"]
}
```

The `Scenario` type is an enum that has two cases `.simple(ScenarioSimple)` & `.outline(ScenarioOutline)`. The parser ensures that a 'Scenario Outline:' must have at least one example.

## Installation

#### Swift Package Manager

To install using Swift Package Manager, add this to the dependencies: section in your Package.swift file:

```swift
.package(url: "https://github.com/iainsmith/SwiftGherkin.git", .upToNextMinor(from: "0.1.0")),
```

<details>
<summary>Example Swift 4 Package</summary>

```swift
let package = Package(
    name: "MyPackage",
    products: [
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/iainsmith/SwiftGherkin.git", .upToNextMinor(from: "0.1.0")),
    ],
    targets: [
        .target(
            name: "MyPackage",
            dependencies: ["Gherkin"])
    ]
)
```
</details>


## Gherkin Subset

#### This package currently has some support for the following Gherkin keywords:

* Feature:
* Scenario:
* Scenario Outline:
  * Examples:
* Steps

#### Obvious areas of improvement include:

* Adding support for
  * Comments
  * Background steps
* Converting a feature file back to the canonical gherkin text
* General Gherkin parsing improvements
* CocoaPods support

If you'd like to add any of these please:

1. Add a test case to GherkinTests.swift
2. Update Parser.swift & Transform.swift until all the tests pass
3. Create a Pull Request

Gherkin is built on top of [Consumer](https://github.com/nicklockwood/Consumer). You will probably want to read the Consumer documentation to work on the parse & transform.

If you'd like to add a different feature to this library, please raise an issue to discuss the details.

## Acknowledgements

Gherkin is built on top of a parser generator called [Consumer](https://github.com/nicklockwood/Consumer) by Nick Lockwood.

## Supported swift versions

SwiftGherkin currently supports swift 4.2 and higher.

## Adding new tests

If you add new tests, run `swift test --generate-linuxmain` to make sure they are added to the `XCTestManifests.swift` file.

## Versioning Notes

The `Feature` type conforms to Codable. It's likely that the JSON representation will not be compatible between versions.

## Other Cucumber/Gherkin Swift Libraries

* [kylef/Ploughman](https://github.com/kylef/Ploughman)
* [Shashikant86/XCFit](https://github.com/Shashikant86/XCFit)
* [net-a-porter-mobile/XCTest-Gherkin](https://github.com/net-a-porter-mobile/XCTest-Gherkin)
