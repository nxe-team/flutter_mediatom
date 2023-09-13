import 'dart:io';

class AdConfig {
  /// 应用ID
  static String get appId {
    if (Platform.isAndroid) {
      return '';
    }
    return '294f913371434775';
  }

  /// 开屏广告
  static String get splashId {
    if (Platform.isAndroid) {
      return '';
    }
    return '03b2e89f588c15d5';
  }

  /// 插屏广告
  static String get interstitialId {
    if (Platform.isAndroid) {
      return '';
    }
    return '548c7d964c146f53';
  }

  /// 信息流广告
  static String get feedId {
    if (Platform.isAndroid) {
      return '';
    }
    return '5bea84e52ecdc13a';
  }
}
