import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mediatom/constants/platform_channel.dart';

class FlutterMediatom {
  @visibleForTesting
  static final methodChannel = MethodChannel(PlatformChannel.plugin.name);

  /// 初始化SDK
  static Future<bool> initSDK({required String appId}) async {
    final result = await methodChannel.invokeMethod<bool>('initSDK', {
      'appId': appId,
    });
    return result ?? false;
  }

  /// 显示开屏广告
  static Future<void> showSplashAd({
    required String slotId,
    String? logo,
    VoidCallback? onAdLoadSuccess,
    VoidCallback? onAdLoadFail,
    VoidCallback? onAdRenderSuccess,
    VoidCallback? onAdDidShow,
    VoidCallback? onAdDidClick,
    VoidCallback? onAdDidClose,
    VoidCallback? onAdFallback,
  }) {
    MethodChannel(PlatformChannel.splashAd.name)
        .setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onAdLoadSuccess':
          onAdLoadSuccess?.call();
          break;
        case 'onAdLoadFail':
          onAdLoadFail?.call();
          break;
        case 'onAdRenderSuccess':
          onAdRenderSuccess?.call();
          break;
        case 'onAdDidShow':
          onAdDidShow?.call();
          break;
        case 'onAdDidClick':
          onAdDidClick?.call();
          break;
        case 'onAdDidClose':
          onAdDidClose?.call();
          break;
        case 'onAdFallback':
          onAdFallback?.call();
          break;
      }
    });
    return methodChannel.invokeMethod('showSplashAd', {
      'slotId': slotId,
      'logo': logo,
    });
  }

  /// 显示开屏广告
  static Future<void> showInterstitialAd({
    required String slotId,
    String? logo,
    VoidCallback? onAdLoadSuccess,
    VoidCallback? onAdLoadFail,
    VoidCallback? onAdDidShow,
    VoidCallback? onAdDidClick,
    VoidCallback? onAdDidClose,
    VoidCallback? onAdFallback,
  }) {
    MethodChannel(PlatformChannel.interstitialAd.name)
        .setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onAdLoadSuccess':
          onAdLoadSuccess?.call();
          break;
        case 'onAdLoadFail':
          onAdLoadFail?.call();
          break;
        case 'onAdDidShow':
          onAdDidShow?.call();
          break;
        case 'onAdDidClick':
          onAdDidClick?.call();
          break;
        case 'onAdDidClose':
          onAdDidClose?.call();
          break;
        case 'onAdFallback':
          onAdFallback?.call();
          break;
      }
    });
    return methodChannel.invokeMethod('showInterstitialAd', {
      'slotId': slotId,
    });
  }
}
