import 'package:flutter/material.dart';
import 'dart:math';
import 'package:bias_profile/commons/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:bias_profile/components/components.dart';
import 'package:bias_profile/util/util.dart';
import 'package:bias_profile/util/RoomStatusMonitor.dart';
import 'package:bias_profile/Pages/ProfileInputPage.dart';

class ProfileInputForm extends StatefulWidget {
  final double containerWidth;
  final String roomId;
  final String playerId;
  final String? correctCardPath;

  const ProfileInputForm({
    super.key,
    required this.containerWidth,
    required this.roomId,
    required this.playerId,
    required this.correctCardPath,
  });

  @override
  State<ProfileInputForm> createState() => _ProfileInputFormState();
}

class _ProfileInputFormState extends State<ProfileInputForm> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: widget.containerWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, kMarginMedium, 0, kMarginMedium),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(kPaddingLarge),
                child: Column(
                  children: [
                    Text(
                      'こちらの人物の見た目から勝手に想像して\n指定したプロフィールを入力してください',
                    ),
                    SizedBox(height: 16.0),
                    if (widget.correctCardPath != null)
                      Image.network(
                        widget.correctCardPath!,
                        width: 195,
                        height: 285,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return CircularProgressIndicator();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Image error: $error'); // デバッグ用
                          return Text('画像の読み込みに失敗しました');
                        },
                      )
                    else
                      Text('画像が見つかりません'),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(
                  kMarginLarge, kMarginMedium, kMarginLarge, kPaddingLarge),
              child: Form(
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  // このお題の表示方法は要検討
                  // 入力欄の上にお題を表示させた方がいいかも
                  decoration: InputDecoration(
                    labelText: '（ここにお題が入る）',
                    labelStyle: Theme.of(context).textTheme.labelMedium,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                print('入力完了');
              },
              child: Text('入力完了'),
            ),
          ],
        ),
      ),
    );
  }
}
