import GherkinCLILib
import Commander

// Other Potential Commands
// * init - Setup the standard folder hierarchy
// * sync --watch --no-steps --generator
Group() {
    let featureDirectory = Option<String>("features", default: "Features", description: "The path to your features")
    let outputDirectory = Option<String>("output", default: "Tests", description: "The path to write tests to")

    $0.command("sync", featureDirectory, outputDirectory) { featurePath, outputPath in
        _ = try GherkinSync.generateTestCode(fromFeatureFolderPath: featurePath,
                                             toOutputPath: outputPath,
                                             using: XCTestGenerator.self)
    }
}.run()
