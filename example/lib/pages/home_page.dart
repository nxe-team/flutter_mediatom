import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mediatom/flutter_mediatom.dart';
import 'package:flutter_mediatom_example/config/ad_config.dart';
import 'package:flutter_mediatom_example/pages/feed_demo.dart';
import 'package:flutter_mediatom_example/pages/splash_page.dart';

/// 首页
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 初始化SDK
  void _initSDK() {
    FlutterMediatom.initSDK(appId: AdConfig.appId, isDebug: true);
  }

  /// 显示开屏广告
  void _showSplashAd() {
    if (Platform.isAndroid) {
      FlutterMediatom.showSplashAd(
        slotId: AdConfig.splashId,
        logo: 'splash_logo',
      );
      return;
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SplashPage()));
  }

  /// 加载插屏广告
  Future<void> _loadInterstitialAd() async {
    await FlutterMediatom.loadInterstitialAd(slotId: AdConfig.interstitialId);
    BotToast.showText(text: '插屏加载完成');
  }

  /// 显示插屏广告
  Future<void> _showInterstitialAd() async {
    await FlutterMediatom.showInterstitialAd(
      onAdDidShow: () {
        BotToast.showText(text: '插屏展示');
      },
      onAdDidClose: () {
        BotToast.showText(text: '插屏关闭');
      },
      onAdDidClick: () {
        BotToast.showText(text: '插屏点击');
      },
    );
    BotToast.showText(text: '调用结束');
  }

  /// 显示信息流广告
  void _showFeedAd() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const FeedDemo()));
  }

  /// 显示激励视频
  void _showRewardVideo() {
    FlutterMediatom.showRewardVideo(slotId: AdConfig.rewardVideoId);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          MaterialButton(
            onPressed: _initSDK,
            child: const Text('初始化SDK'),
          ),
          MaterialButton(
            onPressed: _showSplashAd,
            child: const Text('开屏广告'),
          ),
          MaterialButton(
            onPressed: _loadInterstitialAd,
            child: const Text('加载插屏'),
          ),
          MaterialButton(
            onPressed: _showInterstitialAd,
            child: const Text('展示插屏'),
          ),
          MaterialButton(
            onPressed: _showFeedAd,
            child: const Text('信息流'),
          ),
          MaterialButton(
            onPressed: _showRewardVideo,
            child: const Text('激励视频'),
          ),
        ],
      ),
    );
  }
}
