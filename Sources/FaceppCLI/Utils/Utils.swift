//
//  Utils.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/4.
//

import Foundation
import ArgumentParser
import FaceppSwift
import SwiftGD

struct RuntimeError: Swift.Error, CustomStringConvertible {
    var description: String
    init(_ desc: String) {
        description = desc
    }
}

extension FaceppRectangle: ExpressibleByArgument {
    public init?(argument: String) {
        let values = argument.components(separatedBy: ",")
            .map { Int($0) }.compactMap { $0 }
        guard !values.isEmpty && values.count < 5 else {
            return nil
        }
        self = Self(top: values[0], left: values[1],
                    width: values[2], height: values[3])
    }
}

protocol FaceCLIBaseCommand: ParsableCommand {
    var apiKey: String? { get set }
    var apiSecret: String? { get set }
}

extension FaceCLIBaseCommand {
    func setup() throws {
        guard let key = apiKey ?? FaceppConfig.currentUser?.key,
            let secret = apiSecret ?? FaceppConfig.currentUser?.secret else {
                throw RuntimeError("缺少 api key 和 api secret")
        }
        FaceppClient.initialization(key: key, secret: secret)
    }
}

protocol FaceCLIBasicCommand: FaceCLIBaseCommand {
    var imageURL: String? { get set }
    var imageFile: String? { get set }
    var imageBase64: String? { get set }
    var checkParams: Bool { get set }
    var timeoutInterval: TimeInterval { get set }
}

extension FaceppBaseRequest {
    convenience init(_ command: FaceCLIBasicCommand) throws {
        self.init()
        try command.setup()
        timeoutInterval = command.timeoutInterval
        needCheckParams = command.checkParams
        if let url = command.imageURL {
            imageURL = URL(string: url)
        }
        if let url = command.imageFile {
            imageFile = URL(fileURLWithPath: url)
        }
        imageBase64 = command.imageBase64
    }
}

enum OutputType {
    case error
    case standard
}

func writeMessage<R: FaceppResponseProtocol>(_ message: R?, error: Swift.Error? = nil) {
    if let err = error {
        writeError(err)
    } else if let resp = message {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(resp)
            let output = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            print(output)
        } catch {
            writeError(error)
        }
    }
}

func writeError(_ error: Swift.Error) {
    fputs("\u{001B}[0;31m\(error.localizedDescription)\n", stderr)
}
