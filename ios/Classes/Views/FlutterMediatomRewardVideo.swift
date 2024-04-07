//
//  FlutterMediatomRewardVideo.swift
//  flutter_mediatom
//
//  Created by Anand on 2024/4/7.
//

import Foundation

class FlutterMediatomRewardVideo: FlutterMediatomBase, SFRewardVideoDelegate {
    private let tag: String = "FlutterMediatomRewardVideo"
    private let manager: SFRewardVideoManager

    init(args: [String: Any], result: @escaping FlutterResult, messenger: FlutterBinaryMessenger) {
        manager = SFRewardVideoManager()
        let methodChannel = FlutterMethodChannel(
            name: FlutterMediatomChannel.rewardVideo.rawValue,
            binaryMessenger: messenger)
        super.init(result: result, methodChannel: methodChannel)
        manager.mediaId = args["slotId"] as! String
        manager.delegate = self
        manager.loadAdData(withExtra: nil)
    }
    
    // 广告加载成功
    func rewardedVideoDidLoad() {
        print("\(tag) rewardedVideoDidLoad")
        postMessage("onAdLoadSuccess")
        manager.showRewardVideoAd(with: FlutterMediatomUtil.VC)
    }
    
    // 广告加载失败
    func rewardedVideoDidFailWithError(_ error: any Error) {
        print("\(tag) rewardedVideoDidFailWithError")
        postMessage("onAdLoadFail")
        safeResult(false)
    }
    
    // 广告已展示
    func rewardedVideoDidVisible() {
        print("\(tag) rewardedVideoDidVisible")
        postMessage("onAdDidShow")
    }
    
    // 广告已关闭
    func rewardedVideoDidClose() {
        print("\(tag) rewardedVideoDidClose")
        postMessage("onAdDidClose")
        safeResult(true)
    }
    
    // 广告播放完成可奖励
    func rewardedVideoDidRewardEffective(withExtra extra: [AnyHashable: Any]) {
        print("\(tag) rewardedVideoDidRewardEffective")
        postMessage("onAdDidReward")
    }
    
    // 广告被点击
    func rewardedVideoDidClick() {
        print("\(tag) rewardedVideoDidClick")
        postMessage("onAdDidClick")
    }
}
