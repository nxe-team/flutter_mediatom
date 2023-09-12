import 'package:flutter/material.dart';
import 'package:flutter_mediatom/widgets/mediatom_feed.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView>
    with AutomaticKeepAliveClientMixin {
  double _height = 0.1;

  void _onAdRenderSuccess(double height) {
    print('信息流渲染成功 $height');
    if (height != _height) {
      setState(() {
        _height = height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: _height,
      child: MediatomFeed(
        onAdRenderSuccess: _onAdRenderSuccess,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
