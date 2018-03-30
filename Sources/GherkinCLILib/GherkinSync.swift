//
//  GherkinSync.swift
//  GherkinCLI
//
//  Created by iainsmith on 29/03/2018.
//

import Foundation
import Gherkin
import Files

enum BootstrapError: Error {
    case noFeatureFiles
}

public enum SyncFailure {
    case parserFailure(File)
    case writeFailure(String)
}

public struct SyncResult {
    let updated: [File]
    let failed: [SyncFailure]
}

public enum GherkinSync {
    public static func syncTests(featurePath: String, outputPath: String, generator: XCTestGenerator.Type) throws -> SyncResult {
        let folder = try Folder(path: featurePath)
        let outputFolder = try Folder(path: outputPath)
        let featureFiles = folder.files.filter { $0.extension  == "feature" }.map { $0 }
        guard featureFiles.isEmpty == false else { throw BootstrapError.noFeatureFiles }

        let result = readFeatures(from: featureFiles)
        let features = result.features
        var failedFiles = result.failed

        var success: [File] = []
        for feature in features {
            let testFileText = generator.test(for: feature)
            let fileName = generator.fileName(for: feature)
            guard let data = testFileText.data(using: .utf8) else { continue }
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
}
