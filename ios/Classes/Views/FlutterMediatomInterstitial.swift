//
//  FlutterMediatomInterstitial.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/12.
//

import Foundation
import MSaas

class FlutterMediatomInterstitial: FlutterMediatomBase, SFInterstitialDelegate {
    // 广告管理
    private let manager: SFInterstitialManager

    init(args: [String: Any], result: @escaping FlutterResult, messenger: FlutterBinaryMessenger) {
        manager = SFInterstitialManager()
        let methodChannel = FlutterMethodChannel(
            name: FlutterMediatomChannel.interstitialAd.rawValue,
            binaryMessenger: messenger)
        super.init(result: result, methodChannel: methodChannel)
        manager.delegate = self
        manager.mediaId = args["slotId"] as! String
        manager.showAdController = FlutterMediatomUtil.VC
        manager.loadAdData()

        // 6s后未触发展示则自动关闭
        fallbackTimer = FlutterMediatomTimer.delay(6) {
            self.postMessage("onAdFallback")
            self.safeResult(false)
        }
    }

    // 广告加载成功
    func interstitialAdDidLoad() {
        // 触发时已经结束 -> 不再展示
        if isFulfilled { return }
        postMessage("onAdLoadSuccess")
        manager.showInterstitialAd()
    }

    // 广告加载失败
    func interstitialAdDidFailed(_ error: Error) {
        print("插屏广告加载失败", error)
        postMessage("onAdLoadFail")
        safeResult(false)
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
        safeResult(true)
    }
}
