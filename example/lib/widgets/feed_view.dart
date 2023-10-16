import 'package:flutter/material.dart';
import 'package:flutter_mediatom/widgets/mediatom_feed.dart';
import 'package:flutter_mediatom_example/config/ad_config.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView>
    with AutomaticKeepAliveClientMixin {
  double _height = 320;
  bool _isRenderSuccess = false;
  bool _isRemove = false;

  void _onAdRenderSuccess(double height) {
    print('信息流渲染成功 $height');
    if (_isRenderSuccess && height == _height) return;
    setState(() {
      _isRenderSuccess = true;
      _height = height;
    });
  }

  void _onAdDidClose() {
    setState(() {
      _isRemove = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isRemove) return const SizedBox.shrink();
    return AnimatedSize(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
      child: Offstage(
        offstage: !_isRenderSuccess,
        child: SizedBox(
          height: _height,
          child: MediatomFeed(
            slotId: AdConfig.feedId,
            onAdRenderSuccess: _onAdRenderSuccess,
            onAdDidClose: _onAdDidClose,
            onAdTerminate: _onAdDidClose,
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
