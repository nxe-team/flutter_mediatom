import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import 'package:flutter_mediatom_example/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mediatom AD'),
        ),
        body: const HomePage(),
      ),
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
    );
  }
}
