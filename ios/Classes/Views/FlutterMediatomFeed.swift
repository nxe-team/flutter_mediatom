//
//  FlutterMediatomFeed.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/12.
//

import Foundation
import MSaas

class FlutterMediatomFeedFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        FlutterMediatomFeed(frame: frame, id: viewId, args: args as! [String: Any], messenger: messenger)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}

class FlutterMediatomFeed: NSObject, FlutterPlatformView, SFNativeDelegate {
    // 消息通道
    private let methodChannel: FlutterMethodChannel
    private let container: UIView
    private let manager: SFNativeManager

    func view() -> UIView {
        container
    }

    init(frame: CGRect, id: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(name: "\(FlutterMediatomChannel.feedAd.rawValue)/\(id)", binaryMessenger: messenger)
        container = FlutterMediatomFeedAntiPenetration(frame: frame, methodChannel: methodChannel)
        manager = SFNativeManager()
        super.init()
        manager.delegate = self
        manager.mediaId = args["slotId"] as! String
        manager.adCount = 1
        manager.size = CGSizeMake(UIScreen.main.bounds.size.width, 0)
        manager.showAdController = FlutterMediatomUtil.getVC()
        manager.theme = SFTemplateExpressNativeNormalTheme
        manager.loadAdData()
    }

    // Flutter 通信
    private func postMessage(_ method: String, arguments: [String: Any]? = nil) {
        methodChannel.invokeMethod(method, arguments: arguments)
    }

    // 广告加载成功
    // 加载完成时获取广告高度部分素材为 0
    func nativeAdDidLoad(_ datas: [SFFeedAdData]) {
        postMessage("onAdLoadSuccess")
        let adData: SFFeedAdData = datas.first!
        // 模板广告
        if let ad = adData.adView {
            container.addSubview(ad)
            return
        }
        // 自渲染广告
        adData.isRenderImage = true
        let view = SFTemplateAdView(
            frame: CGRectMake(0, 0, UIScreen.main.bounds.size.width, 0),
            model: adData,
            style: SFTemplateStyleOptions.LIRT,
            lrMargin: 0,
            tbMargin: 0)!
        // 注册后才会渲染素材图片或视频
        manager.registerAdView(forBindImage: view.adImageView, adData: adData, clickableViews: [container])
        // 自渲染高度非0时已经呈现
        container.addSubview(view)
    }

    // 广告加载失败
    func nativeAdDidFailed(_ error: Error) {
        print("信息流广告加载失败", error)
        postMessage("onAdLoadFail")
    }

    // 广告渲染成功 自渲染也会回调
    func nativeAdDidRenderSuccess(withADView nativeAdView: UIView) {
        if let adView = container.subviews.first {
            postMessage("onAdRenderSuccess", arguments: [
                "height": adView.bounds.height
            ])
        }
    }

    // 广告已展示
    func nativeAdDidVisible() {
        postMessage("onAdDidShow")
    }

    // 广告被点击
    func nativeAdDidClicked() {
        postMessage("onAdDidClick")
    }

    // 广告已关闭
    func nativeAdDidClose(withADView nativeAdView: UIView) {
        postMessage("onAdDidClose")
    }
}
