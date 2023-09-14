//
//  FlutterMediatomSplash.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/12.
//

import Foundation
import MSaas

class FlutterMediatomSplash: NSObject, SFSplashDelegate {
    // 结束 Flutter 调用
    private let result: FlutterResult
    // Flutter 通信
    private let methodChannel: FlutterMethodChannel
    // 广告管理
    private let manager: SFSplashManager

    init(args: [String: Any], result: @escaping FlutterResult, messenger: FlutterBinaryMessenger) {
        self.result = result
        methodChannel = FlutterMethodChannel(
            name: FlutterMediatomChannel.splashAd.rawValue,
            binaryMessenger: messenger)
        manager = SFSplashManager()
        super.init()
        manager.delegate = self
        manager.mediaId = args["slotId"] as! String
        // 设置底部 logo
        if let logo = args["logo"] as? String {
            manager.bottomView = FlutterMediaSplashLogo(name: logo)
        }
        manager.loadAdData()
    }

    // Flutter 通信
    private func postMessage(_ method: String, arguments: [String: Any]? = nil) {
        methodChannel.invokeMethod(method, arguments: arguments)
    }

    // 广告加载成功
    func splashAdDidLoad() {
        postMessage("onAdLoadSuccess")
        manager.showSplashAd(with: UIApplication.shared.keyWindow!)
    }

    // 广告加载失败
    func splashAdDidFailed(_ error: Error) {
        print("开屏广告加载失败", error)
        postMessage("onAdLoadFail")
        result(false)
    }

    // 广告渲染成功
    func splashAdDidRender() {
        postMessage("onAdRenderSuccess")
    }

    // 广告成功展示
    func splashAdDidVisible() {
        postMessage("onAdDidShow")
    }

    // 广告被点击
    func splashAdDidClicked(withUrlStr urlStr: String?) {
        postMessage("onAdDidClick")
    }

    // 广告展示完成
    func splashAdDidShowFinish() {
        postMessage("onAdDidClose")
        result(true)
    }
}
