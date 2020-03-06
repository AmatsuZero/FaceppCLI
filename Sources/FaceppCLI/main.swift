import ArgumentParser
import Foundation

enum CommonError: Error {
    case invalidInput(String)
}

func leave(error: Error? = nil) {
    if let err = error {
        writeError(err)
        exit(-1)
    } else {
        exit(EXIT_SUCCESS)
    }
}

let configDir = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask).first?
    .appendingPathComponent("com.daubertjiang.faceppcli")

if let path = configDir?.path,
    !FileManager.default.fileExists(atPath: path) {
    try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
}

struct Facepp: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Face++ 命令行工具",
        subcommands: [
            FppSetupCommand.self,
            FppFacialRecognition.self
        ],
        defaultSubcommand: FppSetupCommand.self)
}

Facepp.main()
