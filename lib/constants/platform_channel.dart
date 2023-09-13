/// 平台通道
enum PlatformChannel {
  /// 插件自身通道
  plugin('flutter_mediatom'),

  /// 开屏广告通道
  splashAd('flutter_mediatom_splash_ad'),

  /// 插屏广告通道
  interstitialAd('flutter_mediatom_interstitial_ad'),

  /// 信息流广告通道
  feedAd('flutter_mediatom_feed_ad');

  final String name;

  const PlatformChannel(this.name);
}
