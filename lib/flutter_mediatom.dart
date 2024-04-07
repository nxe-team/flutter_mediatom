import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mediatom/constants/platform_channel.dart';

class FlutterMediatom {
  @visibleForTesting
  static final methodChannel = MethodChannel(PlatformChannel.plugin.name);

  /// 初始化SDK
  static Future<bool> initSDK(
      {required String appId, bool isDebug = false}) async {
    final result = await methodChannel.invokeMethod<bool>('initSDK', {
      'appId': appId,
      'isDebug': isDebug,
    });
    return result ?? false;
  }

  /// 显示开屏广告
  static Future<void> showSplashAd({
    required String slotId,
    String? logo,
    int? timeout,
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
      'timeout': timeout,
    });
  }

  /// 加载插屏广告
  static Future<bool> loadInterstitialAd({
    required String slotId,
    int? timeout,
  }) async {
    final result = await methodChannel.invokeMethod('loadInterstitialAd', {
      'slotId': slotId,
      'timeout': timeout,
    });
    return result is bool ? result : false;
  }

  /// 显示插屏广告
  static Future<void> showInterstitialAd({
    VoidCallback? onAdDidShow,
    VoidCallback? onAdDidClick,
    VoidCallback? onAdDidClose,
  }) {
    MethodChannel(PlatformChannel.interstitialAd.name)
        .setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onAdDidShow':
          onAdDidShow?.call();
          break;
        case 'onAdDidClick':
          onAdDidClick?.call();
          break;
        case 'onAdDidClose':
          onAdDidClose?.call();
          break;
      }
    });
    return methodChannel.invokeMethod('showInterstitialAd');
  }

  /// 显示激励视频
  static showRewardVideo({
    required String slotId,
    // 加载成功
    VoidCallback? onAdLoadSuccess,
    // 加载失败
    VoidCallback? onAdLoadFail,
    // 已展示
    VoidCallback? onAdDidShow,
    // 已关闭
    VoidCallback? onAdDidClose,
    // 播放完已验证可发放奖励
    VoidCallback? onAdDidReward,
    // 被点击
    VoidCallback? onAdDidClick,
    // 跳过 仅安卓
    VoidCallback? onAdDidSkip,
  }) {
    MethodChannel(PlatformChannel.rewardVideo.name)
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
        case 'onAdDidClose':
          onAdDidClose?.call();
          break;
        case 'onAdDidReward':
          onAdDidReward?.call();
          break;
        case 'onAdDidClick':
          onAdDidClick?.call();
          break;
        case 'onAdDidSkip':
          onAdDidSkip?.call();
          break;
      }
    });
    return methodChannel.invokeMethod('showRewardVideo', {'slotId': slotId});
  }
}
