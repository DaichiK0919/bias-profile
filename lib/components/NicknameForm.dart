import 'package:flutter/material.dart';
import 'package:bias_profile/constants.dart';
import 'package:bias_profile/RoomViewPage.dart';

class NicknameForm extends StatelessWidget {
  final double containerWidth;

  const NicknameForm({super.key, required this.containerWidth});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: containerWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(kPaddingMedium),
              child: Text(
                  style: TextStyle(
                    fontSize: kFontSizeMedium,
                  ),
                  'ニックネームを入力'),
            ),
            Padding(
              padding: EdgeInsets.all(kPaddingMedium),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ヒントテキスト',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(kPaddingLarge),
              child: ElevatedButton(
                onPressed: () {
                  // 画面遷移
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RoomViewPage()));
                  // ここに部屋作成のロジックをお願いします
                },
                child: Text('部屋を作る'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
