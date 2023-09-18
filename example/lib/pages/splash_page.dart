import 'package:flutter/material.dart';
import 'package:flutter_mediatom/flutter_mediatom.dart';
import 'package:flutter_mediatom_example/config/ad_config.dart';

/// 开屏页 用于过渡开屏展示
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    FlutterMediatom.showSplashAd(
      slotId: AdConfig.splashId,
      logo: 'splash_logo',
      onAdDidShow: _onAdDidShow,
      onAdLoadFail: _onAdLoadFail,
      // 兜底无回调
      onAdFallback: _onAdLoadFail,
    );
  }

  // 广告展示
  void _onAdDidShow() {
    // 回业务首页 pushNamed('/')
    Navigator.pop(context);
  }

  // 加载失败
  void _onAdLoadFail() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.white,
      child: SafeArea(
        minimum: EdgeInsets.only(bottom: 40),
        child: Align(
          alignment: Alignment.bottomCenter,
          // 和显示开屏底部一致的 Logo 图用于过渡
          child: Text(
            'Logo',
            style: TextStyle(fontSize: 36),
          ),
        ),
      ),
    );
  }
}
