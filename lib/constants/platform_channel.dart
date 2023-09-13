/// 平台通道
enum PlatformChannel {
  plugin('flutter_mediatom'),
  feedAd('flutter_mediatom_feed_ad');

  final String name;

  const PlatformChannel(this.name);
}
