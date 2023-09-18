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

    init(args: [String: Any], result: @escaping FlutterResult, messenger: FlutterBinaryMessenger) {
        manager = SFSplashManager()
        let methodChannel = FlutterMethodChannel(
            name: FlutterMediatomChannel.splashAd.rawValue,
            binaryMessenger: messenger)
        super.init(result: result, methodChannel: methodChannel)
        manager.delegate = self
        manager.mediaId = args["slotId"] as! String
        // 设置底部 logo
        if let logo = args["logo"] as? String {
            manager.bottomView = FlutterMediaSplashLogo(name: logo)
        }
        manager.loadAdData()

        // 6s后未触发展示则自动关闭
        fallbackTimer = FlutterMediatomTimer.delay(6) {
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

        FlutterMediatomTimer.cancel(fallbackTimer)
        // 6s后未关闭则自动关闭
        fallbackTimer = FlutterMediatomTimer.delay(6) {
            self.postMessage("onAdFallback")
            self.safeResult(true)
        }
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
