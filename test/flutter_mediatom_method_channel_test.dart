import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mediatom/flutter_mediatom_method_channel.dart';

void main() {
  MethodChannelFlutterMediatom platform = MethodChannelFlutterMediatom();
  const MethodChannel channel = MethodChannel('flutter_mediatom');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
