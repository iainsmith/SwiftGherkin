import Consumer
import Foundation

enum GherkinLabel: String {
    case feature, scenario, scenarioOutline, name, description, tag, step, examples, exampleKeys, exampleValues
}

typealias GherkinConsumer = Consumer<GherkinLabel>

func makeParser() -> GherkinConsumer {
    let newLinesSet = CharacterSet.newlines
    let whitespaceCharacters = CharacterSet.whitespaces

    let whitespace: GherkinConsumer = .discard(.zeroOrMore(.character(in: whitespaceCharacters)))
    let nonDiscardedNewLines: GherkinConsumer = .zeroOrMore(.character(in: newLinesSet))
    let newLines: GherkinConsumer = .discard(nonDiscardedNewLines)
    let newLinesSetAndArrows = newLinesSet.union(CharacterSet(charactersIn: "|"))

    let anyCharacters: GherkinConsumer = .oneOrMore(.anyCharacter(except: newLinesSetAndArrows))
    let text: GherkinConsumer = .flatten(anyCharacters)

    func makeLabelAndDescription(startText: String, ignoreText: GherkinConsumer) -> GherkinConsumer {
        let start = GherkinConsumer.string(startText)
        return [
            .label(.name, .flatten([.discard(start), whitespace, text, newLines])),
            .optional(.label(.description, .flatten(.oneOrMore([.not(ignoreText), text, .replace("\n", " "), newLines])))),
        ]
    }
    
    let tagText: GherkinConsumer = .flatten(.oneOrMore(.anyCharacter(except: newLinesSet.union(CharacterSet(charactersIn: "@")))))

    let tag: GherkinConsumer = .label(.tag, .sequence([.discard("@"), tagText, .optional(whitespace), .optional(newLines)]))
    
    let feature: GherkinConsumer = makeLabelAndDescription(startText: "Feature:", ignoreText: "Scenario:" | "Scenario Outline:" | ["@", text])

    let stepKeywords: GherkinConsumer = "Given" | "When" | "Then" | "And" | "But"
    let step: GherkinConsumer = .label(.step, [stepKeywords, whitespace, text, newLines])

    let scenarioName: GherkinConsumer = makeLabelAndDescription(startText: "Scenario:", ignoreText: stepKeywords)
    let scenario: GherkinConsumer = .label(.scenario, [
        .zeroOrMore(tag),
        scenarioName,
        .oneOrMore(step),
    ]
    )

    let discardedPipe: GherkinConsumer = .discard("|")

    let tableRow: GherkinConsumer = [
        .interleaved(discardedPipe, text),
        newLines,
    ]

    let example: GherkinConsumer = [
        .discard("Examples:"),
        newLines,
        .label(.exampleKeys, tableRow),
        .label(.exampleValues, .oneOrMore(tableRow)),
        newLines,
    ]

    let scenarioOutlineName = makeLabelAndDescription(startText: "Scenario Outline:", ignoreText: stepKeywords)
    let scenarioOutline: GherkinConsumer = .label(.scenarioOutline, [
        .zeroOrMore(tag),
        scenarioOutlineName,
        .oneOrMore(step),
        .label(.examples, example),
    ])

    let anyScenario: GherkinConsumer = scenario | scenarioOutline
    let gherkin: GherkinConsumer = .label(.feature, [
        feature,
        .oneOrMore(anyScenario),
    ])
    return gherkin
}

let gherkin = makeParser()
