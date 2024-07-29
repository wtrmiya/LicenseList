import Foundation
import PackagePlugin

@main
struct PrepareLicenseList: BuildToolPlugin {
    struct SourcePackagesNotFoundError: Error & CustomStringConvertible {
        let description: String = "SourcePackages not found"
    }

    func sourcePackages(_ pluginWorkDirectory: Path) throws -> Path {
        var tmpPath = pluginWorkDirectory
        guard pluginWorkDirectory.string.contains("SourcePackages") else {
            throw SourcePackagesNotFoundError()
        }
        while tmpPath.lastComponent != "SourcePackages" {
            tmpPath = tmpPath.removingLastComponent()
        }
        return tmpPath
    }

    func makeBuildCommand(executablePath: Path, sourcePackagesPath: Path, outputPath: Path) -> Command {
        return .buildCommand(
            displayName: "Prepare LicenseList",
            executable: executablePath,
            arguments: [
                outputPath.string,
                sourcePackagesPath.string
            ],
            outputFiles: [
                outputPath.appending(["LicenseList.swift"])
            ]
        )
    }

    // This command works with the plugin specified in `Package.swift`.
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let sppPath = try context.tool(named: "spp").path
        print("spp path: \(sppPath)")
        return [
            makeBuildCommand(
                executablePath: sppPath,
                sourcePackagesPath: try sourcePackages(context.pluginWorkDirectory),
                outputPath: context.pluginWorkDirectory
            )
        ]
    }
}
