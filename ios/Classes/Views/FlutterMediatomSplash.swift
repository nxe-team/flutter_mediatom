//
//  FlutterMediatomSplash.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/12.
//

import Foundation
import MSaas

class FlutterMediatomSplash: FlutterMediatomBase, SFSplashDelegate {
    // 广告管理
    private let manager: SFSplashManager
    // 超时时间
    private let timeout: Double

    init(args: [String: Any], result: @escaping FlutterResult, messenger: FlutterBinaryMessenger) {
        timeout = Double(args["timeout"] as? Int ?? 6)
        manager = SFSplashManager()
        let methodChannel = FlutterMethodChannel(
            name: FlutterMediatomChannel.splashAd.rawValue,
            binaryMessenger: messenger)
        super.init(result: result, methodChannel: methodChannel)
        manager.delegate = self
        manager.mediaId = args["slotId"] as! String
        // 设置超时时间
        manager.timeout = timeout
        // 设置底部 logo
        if let logo = args["logo"] as? String {
            manager.bottomView = FlutterMediaSplashLogo(name: logo)
        }
        manager.loadAdData()

        // 超时后追加1s仍未触发加载成功则自动关闭
        fallbackTimer = FlutterMediatomTimer.delay(timeout + 1) {
            self.postMessage("onAdFallback")
            self.safeResult(false)
        }
    }

    deinit {
        FlutterMediatomTimer.cancel(fallbackTimer)
    }

    // 广告加载成功
    func splashAdDidLoad() {
        // 触发时已经结束 -> 不再展示
        if isFulfilled { return }
        postMessage("onAdLoadSuccess")
        manager.showSplashAd(with: UIApplication.shared.keyWindow!)
        // 取消超时未回调计时
        FlutterMediatomTimer.cancel(fallbackTimer)
    }

    // 广告加载失败
    func splashAdDidFailed(_ error: Error) {
        print("开屏广告加载失败", error)
        postMessage("onAdLoadFail")
        safeResult(false)
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
        safeResult(true)
    }
}
