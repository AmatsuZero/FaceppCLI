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

struct FaceppConfig: Codable {
    var key: String
    var secret: String
    
    static var currentUser: FaceppConfig? = {
        guard let url = configFileURL,
            let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(FaceppConfig.self, from: data)
    }()
    
    func save() throws {
        guard let url = configFileURL else {
            return
        }
        let data = try JSONEncoder().encode(self)
        try data.write(to: url)
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

