import 'flutter_mediatom_platform_interface.dart';

class FlutterMediatom {
  /// 初始化SDK
  static Future<bool> initSDK() {
    return FlutterMediatomPlatform.instance.initSDK();
  }

  /// 显示开屏广告
  static Future<void> showSplashAd() {
    return FlutterMediatomPlatform.instance.showSplashAd();
  }
}
