import Flutter
import MSaas
import UIKit

public class SwiftFlutterMediatomPlugin: NSObject, FlutterPlugin {
    // 开屏广告
    private var splashAd: FlutterMediatomSplash?
    // 插屏广告
    private var interstitialAd: FlutterMediatomInterstitial?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        let channel = FlutterMethodChannel(
            name: FlutterMediatomChannel.plugin.rawValue,
            binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterMediatomPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        // 注册信息流广告 PlatformView
        registrar.register(FlutterMediatomFeedFactory(messenger: messenger), withId: FlutterMediatomChannel.feed_ad.rawValue)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initSDK":
            SFAdSDKManager.registerAppId("294f913371434775")
            SFAdSDKManager.checkSdkIntegration()
            result(true)
        case "showSplashAd":
            splashAd = FlutterMediatomSplash()
            result(true)
        case "showInterstitialAd":
            interstitialAd = FlutterMediatomInterstitial()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
