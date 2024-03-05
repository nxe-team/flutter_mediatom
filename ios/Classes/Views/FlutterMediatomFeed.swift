//
//  FlutterMediatomFeed.swift
//  flutter_mediatom
//
//  Created by Anand on 2023/9/12.
//

import Foundation

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
    // 有渲染成功回调 避开部分模板广告无渲染成功回调
    private var hasRenderSuccessCallback: Bool

    func view() -> UIView {
        container
    }

    init(frame: CGRect, id: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(name: "\(FlutterMediatomChannel.feedAd.rawValue)/\(id)", binaryMessenger: messenger)
        container = FlutterMediatomFeedAntiPenetration(frame: frame, methodChannel: methodChannel)
        manager = SFNativeManager()
        hasRenderSuccessCallback = false
        super.init()
        manager.delegate = self
        manager.mediaId = args["slotId"] as! String
        manager.adCount = 1
        manager.size = CGSizeMake(FlutterMediatomUtil.screenWidth, 0)
        // 广告关闭弹窗未找到响应者的触摸事件会落到 FlutterViewController
        manager.showAdController = FlutterMediatomUtil.VC
        manager.theme = SFTemplateExpressNativeNormalTheme
        manager.loadAdData()
    }

    deinit {
        manager.deallocAllFeedProperty()
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
            frame: CGRectMake(0, 0, FlutterMediatomUtil.screenWidth, 0),
            model: adData,
            style: SFTemplateStyleOptions.LIRT,
            lrMargin: 15,
            tbMargin: 10)!
        // 注册后才会渲染素材图片或视频
        manager.registerAdView(forBindImage: view.adImageView, adData: adData, clickableViews: [container])
        // 自渲染高度非0时已经呈现
        container.addSubview(view)
        // 关闭按钮
        let closeButton = FlutterMediatomCloseButton()
        closeButton.addTarget(self, action: #selector(onTouchUpCloseButton), for: .touchUpInside)
        container.addSubview(closeButton)
    }

    // 点击自渲染广告关闭按钮
    @objc func onTouchUpCloseButton() {
        postMessage("onAdDidClose")
    }

    // 广告加载失败
    func nativeAdDidFailed(_ error: Error) {
        print("信息流广告加载失败", error)
        postMessage("onAdLoadFail")
    }

    // 广告渲染成功 自渲染也会回调
    func nativeAdDidRenderSuccess(withADView nativeAdView: UIView) {
        if let adView = container.subviews.first {
            hasRenderSuccessCallback = adView.bounds.height != 0
            postMessage("onAdRenderSuccess", arguments: [
                "height": adView.bounds.height
            ])
        }
    }

    // 广告已展示
    func nativeAdDidVisible() {
        // 兜底渲染成功回调
        if !hasRenderSuccessCallback, let adView = container.subviews.first {
            postMessage("onAdRenderSuccess", arguments: [
                "height": adView.bounds.height
            ])
        }
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
