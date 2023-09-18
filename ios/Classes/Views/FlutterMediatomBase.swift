//
//  FlutterMediatomBase.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/18.
//

import Foundation

class FlutterMediatomBase: NSObject {
    // 结束 Flutter 调用
    private let result: FlutterResult
    // Flutter 通信
    private let methodChannel: FlutterMethodChannel
    // 兜底关闭计时器
    // 避免无加载成功回调时Flutter一直等待
    var fallbackTimer: GCDTask?
    // 已经返回结果给 Flutter，阻止多次调用 result
    var isFulfilled: Bool = false

    init(result: @escaping FlutterResult, methodChannel: FlutterMethodChannel) {
        self.result = result
        self.methodChannel = methodChannel
    }

    deinit {
        FlutterMediatomTimer.cancel(fallbackTimer)
    }

    // Flutter 通信
    func postMessage(_ method: String, arguments: [String: Any]? = nil) {
        methodChannel.invokeMethod(method, arguments: arguments)
    }

    // 结束 Flutter 调用等待
    func safeResult(_ isOK: Bool) {
        FlutterMediatomTimer.cancel(fallbackTimer)
        if isFulfilled { return }
        result(isOK)
    }
}
