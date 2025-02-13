import 'package:bias_profile/components/ProfileInputForm.dart';
import 'package:flutter/material.dart';
import 'Pages/HomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'commons/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bias_profile/UItest/UItest_ProfileInputForm.dart';
import 'package:bias_profile/UItest/UItest_ProfileAnswerForm.dart';
import 'commons/theme.dart';

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
      theme: AppTheme.lightTheme,
      initialRoute: '/uitest', //for test  UI検証用　遷移後のページのUI作成が難儀にしてきたので
      routes: {
        '/': (context) => const HomePage(),
        '/uitest': (context) => const UitestProfileAnswerForm(),
      },
    );
  }
}
