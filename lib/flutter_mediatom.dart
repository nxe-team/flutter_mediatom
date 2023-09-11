
import 'flutter_mediatom_platform_interface.dart';

class FlutterMediatom {
  Future<String?> getPlatformVersion() {
    return FlutterMediatomPlatform.instance.getPlatformVersion();
  }
}
