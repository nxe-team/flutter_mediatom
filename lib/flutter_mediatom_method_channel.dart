import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_mediatom_platform_interface.dart';

/// An implementation of [FlutterMediatomPlatform] that uses method channels.
class MethodChannelFlutterMediatom extends FlutterMediatomPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_mediatom');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
