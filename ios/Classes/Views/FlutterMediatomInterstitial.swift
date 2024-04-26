//
//  FlutterMediatomInterstitial.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/12.
//

import Foundation

class FlutterMediatomInterstitial: FlutterMediatomBase, SFInterstitialDelegate {
    // 广告管理
    private let manager: SFInterstitialManager
    // 超时时间
    private let timeout: Double
    // 显示结果回调
    private var shownResult: FlutterResult?
    // 已经返回结果给 Flutter，阻止多次调用 result
    private var isFulfilledForShowing: Bool = false
    // 插件入口回调
    private var callback: (() -> Void)?
    // 已加载
    private var isReady: Bool = false
    // 兜底显示计时器
    // 调用展示后，无后续时，结束Flutter调用
    private var showFallbackTimer: GCDTask?

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
            self.safeResult(false)
        }
    }
    
    deinit {
        FlutterMediatomTimer.cancel(showFallbackTimer)
    }

    // 显示插屏
    func show(result: @escaping FlutterResult, callback: @escaping () -> Void) {
        shownResult = result
        self.callback = callback
        if !isReady {
            maybeResultForShowing(false)
            return
        }
        showFallbackTimer = FlutterMediatomTimer.delay(5) {
            self.maybeResultForShowing(false)
        }
        manager.showInterstitialAd()
    }

    // 结束 Flutter 调用等待，显示插屏行为的回调
    func maybeResultForShowing(_ isOK: Bool) {
        if isFulfilledForShowing { return }
        isFulfilledForShowing = true
        if shownResult != nil { shownResult!(isOK) }
        if callback != nil { callback!() }
    }

    // 广告加载成功
    func interstitialAdDidLoad() {
        // 取消超时未回调计时
        FlutterMediatomTimer.cancel(fallbackTimer)
        safeResult(true)
        isReady = true
    }

    // 广告加载失败
    func interstitialAdDidFailed(_ error: Error) {
        print("插屏广告加载失败", error)
        safeResult(false)
    }

    // 广告已展示
    func interstitialAdDidVisible() {
        postMessage("onAdDidShow")
        FlutterMediatomTimer.cancel(showFallbackTimer)
    }

    // 广告被点击
    func interstitialAdDidClick() {
        postMessage("onAdDidClick")
    }

    // 广告已关闭
    func interstitialAdDidClose() {
        postMessage("onAdDidClose")
        maybeResultForShowing(true)
    }
}
