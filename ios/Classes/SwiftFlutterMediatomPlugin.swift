import Flutter
import MSaas
import UIKit

public class SwiftFlutterMediatomPlugin: NSObject, FlutterPlugin {
    private var splashAd: FlutterMediatomSplash?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_mediatom", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterMediatomPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
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
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
