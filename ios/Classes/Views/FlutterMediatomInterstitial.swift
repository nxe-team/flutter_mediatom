//
//  FlutterMediatomInterstitial.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/12.
//

import Foundation
import MSaas

class FlutterMediatomInterstitial: NSObject, SFInterstitialDelegate {
    private let result: FlutterResult
    private let methodChannel: FlutterMethodChannel
    private let manager: SFInterstitialManager

    init(args: [String: Any], result: @escaping FlutterResult, messenger: FlutterBinaryMessenger) {
        self.result = result
        methodChannel = FlutterMethodChannel(
            name: FlutterMediatomChannel.interstitialAd.rawValue,
            binaryMessenger: messenger)
        manager = SFInterstitialManager()
        super.init()
        manager.delegate = self
        manager.mediaId = args["slotId"] as! String
        manager.showAdController = FlutterMediatomUtil.VC
        manager.loadAdData()
    }

    // Flutter 通信
    private func postMessage(_ method: String, arguments: [String: Any]? = nil) {
        methodChannel.invokeMethod(method, arguments: arguments)
    }

    // 广告加载成功
    func interstitialAdDidLoad() {
        postMessage("onAdLoadSuccess")
        manager.showInterstitialAd()
    }

    // 广告加载失败
    func interstitialAdDidFailed(_ error: Error) {
        print("插屏广告加载失败", error)
        postMessage("onAdLoadFail")
        result(false)
    }

    // 广告已展示
    func interstitialAdDidVisible() {
        postMessage("onAdDidShow")
    }

    // 广告被点击
    func interstitialAdDidClick() {
        postMessage("onAdDidClick")
    }

    // 广告已关闭
    func interstitialAdDidClose() {
        postMessage("onAdDidClose")
        result(true)
    }
}
