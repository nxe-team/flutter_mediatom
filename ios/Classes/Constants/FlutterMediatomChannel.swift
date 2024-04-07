//
//  FlutterMediatomChannel.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/12.
//

import Foundation

enum FlutterMediatomChannel: String {
    // 插件自身通道
    case plugin = "flutter_mediatom"
    // 开屏广告通道
    case splashAd = "flutter_mediatom_splash_ad"
    // 插屏广告通道
    case interstitialAd = "flutter_mediatom_interstitial_ad"
    // 信息流广告通道
    case feedAd = "flutter_mediatom_feed_ad"
    // 激励视频广告通道
    case rewardVideo = "flutter_mediatom_reward_video_ad"
}
