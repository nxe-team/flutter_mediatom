import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_mediatom_method_channel.dart';

abstract class FlutterMediatomPlatform extends PlatformInterface {
  /// Constructs a FlutterMediatomPlatform.
  FlutterMediatomPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterMediatomPlatform _instance = MethodChannelFlutterMediatom();

  /// The default instance of [FlutterMediatomPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterMediatom].
  static FlutterMediatomPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterMediatomPlatform] when
  /// they register themselves.
  static set instance(FlutterMediatomPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
