import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MediatomFeed extends StatefulWidget {
  /// 广告渲染成功
  final void Function(double height)? onAdRenderSuccess;

  const MediatomFeed({super.key, this.onAdRenderSuccess});

  @override
  State<MediatomFeed> createState() => _MediatomFeedState();
}

class _MediatomFeedState extends State<MediatomFeed> {
  MethodChannel? _methodChannel;

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onAdRenderSuccess':
        final double height = call.arguments['height'];
        widget.onAdRenderSuccess?.call(height);
        break;
      case 'onAdDidLoad':
        // widget.onAdDidLoad?.call(height);
        break;
      case 'onAdLoadFail':
        // widget.onAdLoadFail?.call(message);
        break;
      case 'onAdViewExposure':
        // widget.onAdViewExposure?.call();
        break;
      case 'onAdDidClick':
        // widget.onAdDidClick?.call();
        break;
      case 'onAdDidClose':
        // widget.onAdDidClose?.call();
        break;
      default:
        throw UnsupportedError("Unsupported method");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return const SizedBox.shrink();
    }
    return UiKitView(
      viewType: 'flutter_mediatom_feed_ad',
      layoutDirection: TextDirection.ltr,
      creationParams: const {'slotId': ''},
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (int id) {
        _methodChannel = MethodChannel('flutter_mediatom_feed_ad/$id');
        _methodChannel!.setMethodCallHandler(_methodCallHandler);
      },
    );
  }
}
