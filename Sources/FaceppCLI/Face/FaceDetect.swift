//
//  FaceDetect.swift
//  FaceppCLI
//
//  Created by 姜振华 on 2020/3/4.
//

import Foundation
import ArgumentParser
import FaceppSwift

extension FaceDetectOption.ReturnAttributes: ExpressibleByArgument, Decodable {
    
}

extension FaceDetectOption.ReturnLandmark: ExpressibleByArgument, Decodable {
    
}

extension Set: ExpressibleByArgument where Element == FaceDetectOption.ReturnAttributes {
    public init?(argument: String) {
        let values = argument
            .components(separatedBy: ",")
            .map { FaceDetectOption.ReturnAttributes(argument: $0) }
            .compactMap { $0 }
        guard !values.isEmpty else {
            return nil
        }
        if values.contains(.none) {
            self = [.none]
        } else {
            self = Set(values)
        }
    }
}

struct FaceppDetect: FaceCLIBasicCommand {
    static var configuration =  CommandConfiguration(
        commandName: "detect",
        abstract: "传入图片进行人脸检测和人脸分析")
    
    @Flag(name: .shortAndLong, default: true, inversion: .prefixedEnableDisable, help: "检查参数")
    var checkParams: Bool
    
    @Option(name:[.customShort("I"), .long], default: 60, help: "超时时间，默认60s")
    var timeoutInterval: TimeInterval
    
    @Option(name: [.customShort("U"), .customLong("url")], help: "图片的 URL")
    var imageURL: String?
    
    @Option(name: [.customShort("F"), .customLong("file")], help: "图片路径")
    var imageFile: String?
    
    @Option(name: .customLong("base64"), help: "base64 编码的二进制图片数据")
    var imageBase64: String?
    
    @Option(name: .customLong("key"), help: "调用此API的API Key")
    var apiKey: String?
        
    @Option(name: .customLong("landmark"), default: .no, help: "是否检测并返回人脸关键点")
    var returnLandmark: FaceDetectOption.ReturnLandmark

    @Option(name: .customLong("attributes"), default: [.none], help: "是否检测并返回人脸关键点")
    var returnAttributes: Set<FaceDetectOption.ReturnAttributes>
       
    @Option(name: .customLong("secret"), help: "调用此API的API Secret")
    var apiSecret: String?
    
    @Option(name: .shortAndLong, help: "是否指定人脸框位置进行人脸检测")
    var faceRectangle: FaceppRectangle?
    
    @Option(name:.customLong("min"), default: 0, help: "颜值评分分数区间的最小值。默认为0")
    var beautyScoreMin: Int
    
    @Option(name: .customLong("max"), default: 100, help: "颜值评分分数区间的最小值。默认为0")
    var beautyScoreMax: Int
    
    @Option(name: .shortAndLong, help: "是否检测并返回所有人脸的人脸关键点和人脸属性")
    var calculateAll: Int?
    
    func run() throws {
        let option = try FaceDetectOption(self)
        option.returnAttributes = returnAttributes
        option.returnLandmark = returnLandmark
        if let flag = calculateAll {
            option.calculateAll = flag == 1
        }
        option.beautyScoreMax = beautyScoreMax
        option.beautyScoreMin = beautyScoreMin
        let sema = DispatchSemaphore(value: 0)
        FaceppSwift.Facepp.detect(option: option) { error, resp in
            guard error == nil else {
                leave(error: error)
                return
            }
            writeMessage(resp)
            sema.signal()
        }.request()
        sema.wait()
    }
}
