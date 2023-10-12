import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mediatom/constants/platform_channel.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MediatomFeed extends StatefulWidget {
  /// 广告位ID
  final String slotId;

  /// 广告加载成功
  final VoidCallback? onAdLoadSuccess;

  /// 广告加载失败
  final VoidCallback? onAdLoadFail;

  /// 广告渲染成功
  final void Function(double height)? onAdRenderSuccess;

  /// 广告展示
  final VoidCallback? onAdDidShow;

  /// 广告被点击
  final VoidCallback? onAdDidClick;

  /// 广告已关闭
  final VoidCallback? onAdDidClose;

  /// 广告被终止
  final VoidCallback? onAdTerminate;

  const MediatomFeed({
    super.key,
    required this.slotId,
    this.onAdRenderSuccess,
    this.onAdLoadSuccess,
    this.onAdLoadFail,
    this.onAdDidShow,
    this.onAdDidClick,
    this.onAdDidClose,
    this.onAdTerminate,
  });

  @override
  State<MediatomFeed> createState() => _MediatomFeedState();
}

class _MediatomFeedState extends State<MediatomFeed> {
  final UniqueKey _detectorKey = UniqueKey();
  MethodChannel? _methodChannel;

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onAdLoadSuccess':
        widget.onAdLoadSuccess?.call();
        break;
      case 'onAdLoadFail':
        widget.onAdLoadFail?.call();
        break;
      case 'onAdRenderSuccess':
        final double height = call.arguments['height'];
        widget.onAdRenderSuccess?.call(height);
        break;
      case 'onAdDidShow':
        widget.onAdDidShow?.call();
        break;
      case 'onAdDidClick':
        widget.onAdDidClick?.call();
        break;
      case 'onAdDidClose':
        widget.onAdDidClose?.call();
        break;
      case 'onAdTerminate':
        widget.onAdTerminate?.call();
        break;
      default:
        throw UnsupportedError("Unsupported method");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return PlatformViewLink(
        viewType: PlatformChannel.feedAd.name,
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: PlatformChannel.feedAd.name,
            layoutDirection: TextDirection.ltr,
            creationParams: {'slotId': widget.slotId},
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () {
              params.onFocusChanged(true);
            },
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener((id) {
              _methodChannel =
                  MethodChannel('${PlatformChannel.feedAd.name}/$id');
              _methodChannel!.setMethodCallHandler(_methodCallHandler);
            })
            ..create();
        },
      );
    }
    return VisibilityDetector(
      key: _detectorKey,
      child: UiKitView(
        viewType: PlatformChannel.feedAd.name,
        layoutDirection: TextDirection.ltr,
        creationParams: {'slotId': widget.slotId},
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (int id) {
          _methodChannel = MethodChannel('${PlatformChannel.feedAd.name}/$id');
          _methodChannel!.setMethodCallHandler(_methodCallHandler);
        },
      ),
      onVisibilityChanged: (VisibilityInfo visibilityInfo) {
        if (!mounted) return;
        // 被遮盖了
        final bool isCovered = visibilityInfo.visibleFraction != 1.0;
        final Offset offset = (context.findRenderObject() as RenderBox)
            .localToGlobal(Offset.zero);
        _methodChannel?.invokeMethod('updateVisibleBounds', {
          'isCovered': isCovered,
          'x': offset.dx + visibilityInfo.visibleBounds.left,
          'y': offset.dy + visibilityInfo.visibleBounds.top,
          'width': visibilityInfo.visibleBounds.width,
          'height': visibilityInfo.visibleBounds.height,
        });
      },
    );
  }
}
