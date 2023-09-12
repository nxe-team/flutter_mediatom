import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_mediatom_platform_interface.dart';

/// An implementation of [FlutterMediatomPlatform] that uses method channels.
class MethodChannelFlutterMediatom extends FlutterMediatomPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_mediatom');

  @override
  Future<bool> initSDK() async {
    final result = await methodChannel.invokeMethod<bool>('initSDK');
    return result ?? false;
  }

  @override
  Future<void> showSplashAd() async {
    await methodChannel.invokeMethod('showSplashAd');
  }

  @override
  Future<void> showInterstitialAd() async {
    await methodChannel.invokeMethod('showInterstitialAd');
  }
}
