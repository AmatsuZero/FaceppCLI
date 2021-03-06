//
//  Beautify.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/5.
//

import Foundation
import FaceppSwift
import ArgumentParser

extension BeautifyV2Option.FilterType: ExpressibleByArgument, Decodable {}

struct FppFaceBeautifyCommand: FaceCLIBasicCommand {
    static var configuration = CommandConfiguration(
        commandName: "beautify",
        abstract: """
        V1: 对图片进行美颜和美白。
        V2: 支持对图片中人像进行对美颜美型处理，以及对图像增加滤镜等。美颜包括：美白和磨皮；美型包括：大眼、瘦脸、小脸和去眉毛等处理。
        """,
        discussion: """
        图片要求:

        -- 图片格式：JPG(JPEG)，PNG
        -- 图片像素尺寸：最小48*48像素，最大4096*4096像素
        -- 图片文件大小：<=2MB
        """)
    
    @Option(name: .shortAndLong, default: 2, help: "使用的API版本")
    var version: Int
    
    @Flag(default: true, inversion: .prefixedEnableDisable, help: "检查参数")
    var checkParams: Bool
    
    @Flag(default: false, inversion: .prefixedEnableDisable, help: "请求报告，macOS only")
    var metrics: Bool
    
    @Option(name:[.customShort("T"), .long], default: 60, help: "超时时间，默认60s")
    var timeout: TimeInterval
    
    @Option(name: [.customShort("U"), .customLong("url")], help: "图片的 URL")
    var imageURL: String?
    
    @Option(name: [.customShort("F"), .customLong("file")], help: "图片路径")
    var imageFile: String?
    
    @Option(name: .customLong("base64"), help: "base64 编码的二进制图片数据")
    var imageBase64: String?
    
    @Option(name: .customLong("key"), help: "调用此API的API Key")
    var apiKey: String?
    
    @Option(name: .customLong("secret"), help: "调用此API的API Secret")
    var apiSecret: String?
    
    @Option(default: 50, help: "瘦脸程度，取值范围 [0,100]")
    var thinface: UInt
    
    @Option(default: 50, help: "美白程度，取值范围[0,100]")
    var whitening: UInt
    
    @Option(default: 50, help: "磨皮程度，取值范围 [0,100]")
    var smoothing: UInt
    
    @Option(default: 50, help: "小脸程度，取值范围 [0,100]")
    var shrinkFace: UInt
    
    @Option(default: 50, help: "大眼程度，取值范围 [0,100]")
    var enlargeEye: UInt
    
    @Option(default: 50, help: "去眉毛程度，取值范围 [0,100]")
    var removeEyebrow: UInt
    
    @Option(help: "滤镜名称, 可用滤镜见官网，默认无滤镜")
    var filterType: BeautifyV2Option.FilterType?
    
    func run() throws {
        let sema = DispatchSemaphore(value: 0)
        if version == 2 {
            try runV1(sema)
        } else {
            try runV2(sema)
        }
    }
}

private extension FppFaceBeautifyCommand {
    func runV1(_ sema: DispatchSemaphore) throws {
        let option = try BeautifyV1Option(self)
        option.smoothing = smoothing
        option.whitening = whitening
        FaceppSwift.Facepp.beautifyV1(option: option) { error, resp in
            commonResponseHandler(sema, error: error, resp: resp)
        }.request()
        sema.wait()
    }
    
    func runV2(_ sema: DispatchSemaphore) throws {
        let option = try BeautifyV2Option(self)
        option.smoothing = smoothing
        option.whitening = whitening
        option.enlargeEye = enlargeEye
        option.filterType = filterType
        option.removeEyebrow = removeEyebrow
        option.shrinkFace = shrinkFace
        option.thinface = thinface
        
        semaRun { sema in
            FaceppSwift.Facepp.beautifyV2(option: option) { error, resp in
                commonResponseHandler(sema, error: error, resp: resp)
            }.request()
        }
    }
}
