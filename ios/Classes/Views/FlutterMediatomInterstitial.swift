//
//  FlutterMediatomInterstitial.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/12.
//

import Foundation
import MSaas

class FlutterMediatomInterstitial: NSObject, SFInterstitialDelegate {
    private var manager: SFInterstitialManager

    override init() {
        manager = SFInterstitialManager()
        super.init()
        manager.delegate = self
        manager.mediaId = "548c7d964c146f53"
        manager.showAdController = FlutterMediatomUtil.getVC()
        manager.loadAdData()
    }

    // 广告加载成功
    func interstitialAdDidLoad() {
        manager.showInterstitialAd()
    }

    // 广告加载失败
    func interstitialAdDidFailed(_ error: Error) {
        print("插屏广告加载失败", error)
    }

    // 广告被点击
    func interstitialAdDidClick() {}

    // 广告已关闭
    func interstitialAdDidClose() {}
}
