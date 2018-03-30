//
//  GherkinSync.swift
//  GherkinCLI
//
//  Created by iainsmith on 29/03/2018.
//

import Foundation
import Gherkin
import Files

public typealias Generator = XCTestGenerator

/// TODO: We should seperate the generating of the contents from writting to the disk.
public enum GherkinSync {
    public static func generateTestCode(fromFeatureFolderPath featurePath: String,
                                        toOutputPath outputPath: String,
                                        using generator: Generator.Type) throws -> SyncResult {
        let folder = try Folder(path: featurePath)
        let output: Folder = try Folder(path: outputPath)
        let featureFiles = folder.files.filter { $0.extension  == "feature" }.map { $0 }
        guard featureFiles.isEmpty == false else { throw GherkinSyncError.noFeatureFiles }

        let readResult = readFeatures(from: featureFiles)
        let features = readResult.features
        let failedReads = readResult.failed

        let writeResult = writeSteps(for: features, to: output, using: generator)
        let result = writeResult.appending(failedReads)

        let stubsResult = try writeTestsStubs(for: features, to: output, using: generator)
        return result.appending(stubsResult)
    }

    static func readFeatures(from files: [File]) -> (features: [Feature], failed: [SyncFailure]) {
        var failedFiles = [SyncFailure]()
        let features: [Feature] = files.flatMap { file in
            do  {
                return try Feature(file.readAsString())
            } catch {
                let failure = SyncFailure.parserFailure(file)
                failedFiles.append(failure)
                return nil
            }
        }
        return (features, failedFiles)
    }

    static func writeTestsStubs(for features: [Feature], to outputFolder: Folder, using generator: Generator.Type) throws -> SyncResult {
        let testFileName = generator.stepFileName

        let steps = features.map { generator.testStubs(for: $0)}.unique().sorted()
        let text = steps.joined(separator: "\n")
        let file = try outputFolder.createFileIfNeeded(withName: testFileName)
        try file.append(string: text)
        return SyncResult(updated: [file], failed: [])
    }

    static func writeSteps(for features: [Feature], to outputFolder: Folder, using generator: Generator.Type) -> SyncResult {
        var failedFiles = [SyncFailure]()
        var success: [File] = []
        for feature in features {
            let stepsText = generator.test(for: feature)
            let fileName = generator.featureFileName(for: feature)
            guard let data = stepsText.data(using: .utf8) else { continue }
            do {
                let file = try outputFolder.createFileIfNeeded(withName: fileName, contents: data)
                success.append(file)
            } catch {
                let failure = SyncFailure.writeFailure(fileName)
                failedFiles.append(failure)
            }
        }
        return SyncResult(updated: success, failed: failedFiles)
    }
}
