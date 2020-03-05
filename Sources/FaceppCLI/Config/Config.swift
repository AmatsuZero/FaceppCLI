//
//  Users.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/3.
//

import ArgumentParser
import Foundation
import FaceppSwift

let configFileURL = configDir?.appendingPathComponent("config")

class FaceppConfig: Codable {
    var key: String
    var secret: String
    
    static var currentUser: FaceppConfig? = {
        guard let url = configFileURL,
            let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(FaceppConfig.self, from: data)
    }()
    
    init(key: String, secret: String) {
        self.key = key
        self.secret = secret
    }
    
    func save() throws {
        guard let url = configFileURL else {
            return
        }
        let data = try JSONEncoder().encode(self)
        try data.write(to: url)
    }
}

extension FaceppConfig: FaceppMetricsReporter {
    @available(OSX 10.12, *)
    func option(_ option: FaceppRequestConfigProtocol, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        print(metrics)
    }
}

struct FaceppSetup: ParsableCommand {
    static var configuration =  CommandConfiguration(
        commandName: "setup",
        abstract: "执行设置"
    )
    
    @Option(name:.shortAndLong, help: "api key")
    var key: String
    
    @Option(name:.shortAndLong, help: "api secret")
    var secret: String
    
    func run() throws {
        FaceppConfig.currentUser = FaceppConfig(key: key, secret: secret)
        try FaceppConfig.currentUser?.save()
    }
}

func semaRun(_ value: Int = 0, block: (DispatchSemaphore) -> Void) {
    let sema = DispatchSemaphore(value: value)
    block(sema)
    sema.wait()
}
