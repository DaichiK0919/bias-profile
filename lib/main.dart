import 'package:flutter/material.dart';
import 'HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '偏見プロフィール',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
      ),
      home: HomePage(),
    );
  }
}
