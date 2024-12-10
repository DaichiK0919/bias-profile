import 'package:flutter/material.dart';
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
  final List<String> otherCardPaths;
  final String? assignedProfileTheme;

  const ProfileInputForm({
    super.key,
    required this.containerWidth,
    required this.roomId,
    required this.playerId,
    required this.correctCardPath,
    this.otherCardPaths = const [],
    required this.assignedProfileTheme,
  });

  @override
  State<ProfileInputForm> createState() => _ProfileInputFormState();
}

class _ProfileInputFormState extends State<ProfileInputForm> {
  bool _hasPrecached = false; // didChangeDependencies での重複実行を防ぐためのフラグ
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _profileController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasPrecached) {
      // 他の画像を非同期でプリキャッシュ
      for (final path in widget.otherCardPaths) {
        precacheImage(
          NetworkImage(path),
          context,
        ).then((_) {
          print('Precached other image: $path');
        }).catchError((e) {
          print('Other image precaching error: $e');
        });
      }
      _hasPrecached = true;
    }
  }

  bool isValidProfile(String profile) {
    return profile.isNotEmpty && profile.length <= 100;
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
                        width: kProfileImageWidth,
                        height: kProfileImageHeight,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Image error: $error');
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.assignedProfileTheme!,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      validator: (value) {
                        if (!isValidProfile(value!)) {
                          return '1〜100文字で入力してください';
                        }
                        return null;
                      },
                      controller: _profileController,
                      keyboardType: TextInputType.multiline,
                      maxLines: kProfileMaxLine,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  print('入力完了');
                } else {
                  print('入力失敗');
                }
              },
              child: Text('入力完了'),
            ),
          ],
        ),
      ),
    );
  }
}
