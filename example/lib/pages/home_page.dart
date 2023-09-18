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
    FlutterMediatom.initSDK(appId: AdConfig.appId);
  }

  /// 显示开屏广告
  void _showSplashAd() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SplashPage()));
  }

  /// 显示插屏广告
  void _showInterstitialAd() {
    FlutterMediatom.showInterstitialAd(slotId: AdConfig.interstitialId);
  }

  /// 显示信息流广告
  void _showFeedAd() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const FeedDemo()));
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
            onPressed: _showInterstitialAd,
            child: const Text('插屏广告'),
          ),
          MaterialButton(
            onPressed: _showFeedAd,
            child: const Text('信息流广告'),
          ),
        ],
      ),
    );
  }
}
