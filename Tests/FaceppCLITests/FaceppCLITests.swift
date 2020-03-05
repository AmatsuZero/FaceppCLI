import XCTest
import class Foundation.Bundle

final class FaceppCLITests: XCTestCase {
    
    let key = ProcessInfo.processInfo.environment["key"]
    let secret = ProcessInfo.processInfo.environment["secret"]
    
    override func setUp() {
        XCTAssertNotNil(key)
        XCTAssertNotNil(secret)
    }
    
    func testSetup() throws {
        guard #available(macOS 10.13, *) else {
            fatalError()
        }
        let process = getProcess([
            "setup",
            "--key", key!,
            "--secret", secret!
        ])
        try process.run()
        process.waitUntilExit()
        guard let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("com.daubertjiang.faceppcli")
            .appendingPathComponent("config") else {
                return
        }
        let data = try Data(contentsOf: url)
        let obj = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: String]
        XCTAssertEqual(obj?["key"]! == key, obj?["secret"] == secret)
    }
    
    func testFaceDetect() throws {
        guard #available(macOS 10.13, *) else {
            fatalError()
        }
        let process = getProcess([
            "face", "detect",
            "--url", "http://5b0988e595225.cdn.sohucs.com/images/20191103/9c9bdf0a89a44cb59d16cae007951af8.jpeg",
            "--timeoutInterval", "30"
        ])
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        XCTAssertNotNil(output)
        XCTAssertTrue(!output!.contains("errorMessage"))
    }
    
    /// Returns path to the built products directory.
    var productsDirectory: URL {
        #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
        #else
        return Bundle.main.bundleURL
        #endif
    }
    
    func getProcess(_ arguments: [String]) -> Process {
        guard #available(macOS 10.13, *) else {
            fatalError()
        }
        let fooBinary = productsDirectory.appendingPathComponent("FaceppCLI")
        let process = Process()
        process.executableURL = fooBinary
        process.arguments = arguments
        return process
    }
    
    static var allTests = [
        ("testSetup", testSetup),
    ]
}
