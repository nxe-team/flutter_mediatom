import 'package:flutter/material.dart';
import 'package:flutter_mediatom_example/widgets/feed_view.dart';

/// 信息流案例
class FeedDemo extends StatefulWidget {
  const FeedDemo({super.key});

  @override
  State<FeedDemo> createState() => _FeedDemoState();
}

class _FeedDemoState extends State<FeedDemo> {
  Widget _buildFeedAd(BuildContext context, int index) {
    if (index % 5 == 0) {
      return const FeedView();
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xffcccccc),
          width: 1,
        ),
      ),
      height: 200,
      child: Text(index.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Demo'),
      ),
      body: ListView.builder(itemBuilder: _buildFeedAd),
    );
  }
}
