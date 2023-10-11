import 'dart:io';

class AdConfig {
  /// 应用ID
  static String get appId {
    if (Platform.isAndroid) {
      return 'c1309807af3901ff';
    }
    return '294f913371434775';
  }

  /// 开屏广告
  static String get splashId {
    if (Platform.isAndroid) {
      return '9f525ca64292750c';
    }
    return '03b2e89f588c15d5';
  }

  /// 插屏广告
  static String get interstitialId {
    if (Platform.isAndroid) {
      return '8df42ba44023db35';
    }
    return '548c7d964c146f53';
  }

  /// 信息流广告
  static String get feedId {
    if (Platform.isAndroid) {
      return '7b0eecb255844aeb';
    }
    return '5bea84e52ecdc13a';
  }
}
