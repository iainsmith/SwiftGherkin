//
//  GherkinSyncModels.swift
//  GherkinCLILib
//
//  Created by iainsmith on 30/03/2018.
//

import Foundation
import Files

enum GherkinSyncError: Error {
    case noFeatureFiles
}

public enum SyncFailure {
    case parserFailure(File)
    case writeFailure(String)
}

public struct SyncResult {
    let updated: [File]
    let failed: [SyncFailure]

    func appending(_ failures: [SyncFailure]) -> SyncResult {
        return SyncResult(updated: updated, failed: failed + failures)
    }

    func appending(_ result: SyncResult) -> SyncResult {
        return SyncResult(updated: updated + result.updated, failed: failed + result.failed)
    }
}
