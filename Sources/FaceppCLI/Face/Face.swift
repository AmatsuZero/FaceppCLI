//
//  Face.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/4.
//

import Foundation
import ArgumentParser

struct FacesetCommand: ParsableCommand {
    static var configuration =  CommandConfiguration(
        commandName: "faceset",
        abstract: "人脸集合",
        subcommands: [])
}

struct FacialRecognition: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "face",
        abstract: "人脸识别",
        subcommands: [
            FaceppDetectCommand.self,
            FaceppCompareCommand.self,
            FacesetCommand.self,
            FaceBeautifyCommand.self,
            FaceppFeaturesCommand.self
        ]
    )
}
