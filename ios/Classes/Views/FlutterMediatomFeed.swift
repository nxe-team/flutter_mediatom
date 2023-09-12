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
        methodChannel = FlutterMethodChannel(name: "\(FlutterMediatomChannel.feed_ad)/\(id)", binaryMessenger: messenger)
        container = UIView()
        manager = SFNativeManager()
        super.init()
        manager.delegate = self
        manager.mediaId = "5bea84e52ecdc13a"
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
        let adData: SFFeedAdData = datas.first!
        // 模板广告
        if let ad = adData.adView {
            print("信息流广告加载成功-模板 \(ad.bounds.height)")
            container.addSubview(ad)
            return
        }
        // 自渲染广告
        print("信息流广告加载成功-自渲染")
        adData.isRenderImage = true
        let view = SFTemplateAdView(frame: CGRectMake(0, 0, UIScreen.main.bounds.size.width, 0), model: adData, style: SFTemplateStyleOptions.LIRT, lrMargin: 0, tbMargin: 0)!
        print("自渲染广告高度 \(view.bounds.height)")
        container.addSubview(view)
    }

    // 广告加载失败
    func nativeAdDidFailed(_ error: Error) {
        print("信息流广告加载失败", error)
    }

    // 广告渲染成功 自渲染也会回调
    func nativeAdDidRenderSuccess(withADView nativeAdView: UIView) {
        print("信息流广告加载成功-模板 \(nativeAdView) \(container.subviews.first?.bounds.height)")
        postMessage("onAdRenderSuccess", arguments: [
            "height": container.subviews.first?.bounds.height
        ])
    }
}
