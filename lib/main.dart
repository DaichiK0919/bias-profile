import 'package:flutter/material.dart';

final double kSizeBoxHeight = 16;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bias-profile',
      home: BiasProfileHome(),
    );
  }
}

class BiasProfileHome extends StatelessWidget {
  const BiasProfileHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('偏見プロフィール'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ニックネームを入力'),
              SizedBox(
                height: kSizeBoxHeight,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'この中に文字を入れることも可能',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: kSizeBoxHeight,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BiasProfileRoomView()));
                },
                child: Text('部屋を作る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BiasProfileRoomView extends StatelessWidget {
  const BiasProfileRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Column(
              children: [
                Text('参加メンバー'),
                SizedBox(
                  height: kSizeBoxHeight,
                ),
                Text('ここに参加メンバーを表示'),
                SizedBox(
                  height: kSizeBoxHeight,
                ),
                Text('部屋リンク'),
                SizedBox(
                  height: kSizeBoxHeight,
                ),
                Text('部屋リンクURLを表示'),
                SizedBox(
                  height: kSizeBoxHeight,
                ),
                ElevatedButton(
                  onPressed: () {
                    print('clicked!');
                  },
                  child: Text('締め切る'),
                ),
                SizedBox(
                  height: kSizeBoxHeight,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('キャンセル'),
                )
              ],
            ),
          )
        ],
      ),
    ));
  }
}
