//
//  Beautify.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/5.
//

import Foundation
import FaceppSwift
import ArgumentParser

extension BeautifyV2Option.FilterType: ExpressibleByArgument {
    
}

struct FaceBeautyCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "beauty",
        abstract: "支持对图片中人像进行对美颜美型处理，以及对图像增加滤镜等.美颜包括：美白和磨皮；美型包括：大眼、瘦脸、小脸和去眉毛等处理")
    
     @Option(name: .shortAndLong, default: 2, help: "使用API版本")
    var version: Int
}
