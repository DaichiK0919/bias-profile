import 'package:flutter/material.dart';
import 'RoomCreatePage.dart';
import 'RoomEnterPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      initialRoute: '/join', //参加者テスト用　必ず消す！！
      routes: {
        '/': (context) => const RoomCreatePage(),
        '/join': (context) => const RoomEnterPage(), //参加者テスト用　必ず消す！！
      },
    );
  }
}
