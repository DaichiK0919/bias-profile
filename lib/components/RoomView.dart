import 'package:flutter/material.dart';
import 'package:bias_profile/constants.dart';

class RoomView extends StatelessWidget {
  final double containerWidth;

  const RoomView({
    super.key,
    required this.containerWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: containerWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(16.0), // 角を丸くする
              ),
              child: Padding(
                padding: EdgeInsets.all(kPaddingLarge),
                child: Column(
                  children: [
                    Text('参加メンバー'),
                    Text('ここに参加メンバーを表示'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(kPaddingLarge),
              child: Container(
                child: Column(
                  children: [
                    Text('部屋リンク'),
                    Text('部屋リンクURLを表示'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(kPaddingMedium),
              child: ElevatedButton(
                onPressed: () {
                  print('clicked!');
                },
                child: Text('締め切る'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(kPaddingMedium),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('キャンセル'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
