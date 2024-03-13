import Flutter
import UIKit

public class SwiftFlutterMediatomPlugin: NSObject, FlutterPlugin {
    // Flutter Messenger
    private static var messenger: FlutterBinaryMessenger?
    // 开屏广告
    private var splashAd: FlutterMediatomSplash?
    // 插屏广告
    private var interstitialAd: FlutterMediatomInterstitial?

    public static func register(with registrar: FlutterPluginRegistrar) {
        messenger = registrar.messenger()
        let channel = FlutterMethodChannel(
            name: FlutterMediatomChannel.plugin.rawValue,
            binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterMediatomPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        // 注册信息流广告 PlatformView
        registrar.register(FlutterMediatomFeedFactory(messenger: messenger!), withId: FlutterMediatomChannel.feedAd.rawValue)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        switch call.method {
        case "initSDK":
            SFAdSDKManager.registerAppId(args["appId"] as! String)
            SFAdSDKManager.checkSdkIntegration()
            result(true)
        case "showSplashAd":
            splashAd = FlutterMediatomSplash(
                args: args,
                result: result,
                messenger: SwiftFlutterMediatomPlugin.messenger!)
        case "loadInterstitialAd":
            interstitialAd = FlutterMediatomInterstitial(
                args: args,
                result: result,
                messenger: SwiftFlutterMediatomPlugin.messenger!)
        case "showInterstitialAd":
            if interstitialAd == nil {
                result(false)
                return
            }
            interstitialAd!.show(result: result, callback: clearInterstitialAd)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func clearInterstitialAd() {
        interstitialAd = nil
    }
}
