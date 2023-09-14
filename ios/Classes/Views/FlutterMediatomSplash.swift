//
//  FlutterMediatomSplash.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/12.
//

import Foundation
import MSaas

class FlutterMediatomSplash: NSObject, SFSplashDelegate {
    private var manager: SFSplashManager

    override init() {
        manager = SFSplashManager()
        super.init()
        manager.delegate = self
        manager.mediaId = "03b2e89f588c15d5"
        manager.bottomView = FlutterMediaSplashLogo(name: "splash_logo")
        manager.loadAdData()
    }

    // 广告加载成功
    func splashAdDidLoad() {
        manager.showSplashAd(with: UIApplication.shared.keyWindow!)
    }

    // 广告加载失败
    func splashAdDidFailed(_ error: Error) {
        print("开屏广告加载失败", error)
    }

    // 广告展示完成
    func splashAdDidShowFinish() {}
}
