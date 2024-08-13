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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'ニックネームを入力',
                    labelStyle: Theme.of(context).textTheme.labelMedium,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
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
