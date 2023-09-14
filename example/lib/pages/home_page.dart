import 'package:flutter/material.dart';
import 'package:flutter_mediatom/flutter_mediatom.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 初始化SDK
  void _initSDK() {
    FlutterMediatom.initSDK();
  }

  /// 显示开屏广告
  void _showSplashAd() {
    FlutterMediatom.showSplashAd();
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
        ],
      ),
    );
  }
}
