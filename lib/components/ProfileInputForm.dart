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

  const ProfileInputForm({
    super.key,
    required this.containerWidth,
    required this.roomId,
    required this.playerId,
    required this.correctCardPath,
    required this.otherCardPaths,
  });

  @override
  State<ProfileInputForm> createState() => _ProfileInputFormState();
}

class _ProfileInputFormState extends State<ProfileInputForm> {
  bool _isImageLoading = true; // 画像の読み込み状態を管理

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheAllImages();
  }

  Future<void> _precacheAllImages() async {
    if (!mounted) return;

    try {
      // 正解の画像を事前読み込み
      if (widget.correctCardPath != null) {
        await precacheImage(
          NetworkImage(widget.correctCardPath!),
          context,
        );
      }

      // その他の画像も事前読み込み
      for (final path in widget.otherCardPaths) {
        await precacheImage(
          NetworkImage(path),
          context,
        );
      }
    } catch (e) {
      print('Image precaching error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isImageLoading = false;
        });
      }
    }
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
                      _isImageLoading
                          ? CircularProgressIndicator()
                          : Image.network(
                              widget.correctCardPath!,
                              width: kProfileImageWidth,
                              height: kProfileImageHeight,
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
                  Text('ここにお題を表示'),
                  Form(
                    child: TextFormField(
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
