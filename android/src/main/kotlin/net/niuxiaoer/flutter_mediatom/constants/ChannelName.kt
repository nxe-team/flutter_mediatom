package net.niuxiaoer.flutter_mediatom.constants

/** 消息通道名称 */
enum class ChannelName(val value: String) {
    // 插件自身通道
    PLUGIN("flutter_mediatom"),

    // 开屏广告通道
    SPLASH_AD("flutter_mediatom_splash_ad"),

    // 插屏广告通道
    INTERSTITIAL_AD("flutter_mediatom_interstitial_ad"),

    // 信息流广告通道
    FEED_AD("flutter_mediatom_feed_ad"),

    // 激励视频广告通道
    REWARD_VIDEO("flutter_mediatom_reward_video_ad")
}
