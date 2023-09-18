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
    // 超时时间
    private let timeout: Double

    init(args: [String: Any], result: @escaping FlutterResult, messenger: FlutterBinaryMessenger) {
        timeout = Double(args["timeout"] as? Int ?? 6)
        manager = SFInterstitialManager()
        let methodChannel = FlutterMethodChannel(
            name: FlutterMediatomChannel.interstitialAd.rawValue,
            binaryMessenger: messenger)
        super.init(result: result, methodChannel: methodChannel)
        manager.delegate = self
        manager.mediaId = args["slotId"] as! String
        manager.timeout = timeout
        manager.showAdController = FlutterMediatomUtil.VC
        manager.loadAdData()

        // 超时后追加1s仍未触发加载成功则自动关闭
        fallbackTimer = FlutterMediatomTimer.delay(timeout + 1) {
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
        // 取消超时未回调计时
        FlutterMediatomTimer.cancel(fallbackTimer)
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
