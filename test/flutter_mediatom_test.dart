import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mediatom/flutter_mediatom.dart';
import 'package:flutter_mediatom/flutter_mediatom_platform_interface.dart';
import 'package:flutter_mediatom/flutter_mediatom_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterMediatomPlatform
    with MockPlatformInterfaceMixin
    implements FlutterMediatomPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterMediatomPlatform initialPlatform = FlutterMediatomPlatform.instance;

  test('$MethodChannelFlutterMediatom is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterMediatom>());
  });

  test('getPlatformVersion', () async {
    FlutterMediatom flutterMediatomPlugin = FlutterMediatom();
    MockFlutterMediatomPlatform fakePlatform = MockFlutterMediatomPlatform();
    FlutterMediatomPlatform.instance = fakePlatform;

    expect(await flutterMediatomPlugin.getPlatformVersion(), '42');
  });
}
