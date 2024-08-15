import 'package:flutter/material.dart';
import 'package:bias_profile/constants.dart';
import 'package:bias_profile/RoomViewPage.dart';

class RoomCreateForm extends StatefulWidget {
  final double containerWidth;

  const RoomCreateForm({super.key, required this.containerWidth});

  @override
  State<RoomCreateForm> createState() => _RoomCreateFormState();
}

class _RoomCreateFormState extends State<RoomCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController =
      TextEditingController(); //入力されたニックネームのStateを管理

  bool isValidNickname(String nickname) {
    // 文字数制限の例
    if (nickname.length > 10) {
      return false;
    }
    // // 使用可能な文字の制限の例 (アルファベットと数字のみ)
    // RegExp regex = RegExp(r'^[a-zA-Z0-9]+$');
    // if (!regex.hasMatch(nickname)) {
    //   return false;
    // }
    // // 禁止ワードのチェック (例: admin)
    // if (nickname.toLowerCase() == 'admin') {
    //   return false;
    // }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: widget.containerWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ニックネームを入力してください。';
                      }
                      if (!isValidNickname(value!)) {
                        return 'ニックネームは10文字以下で入力してください。';
                      }
                      return null;
                    },
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      labelText: 'ニックネームを入力',
                      labelStyle: Theme.of(context).textTheme.labelMedium,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(kPaddingLarge),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // バリデーションが成功した場合
                    String nickname = _nicknameController.text;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomViewPage(nickname: nickname),
                      ),
                    );
                    // 部屋作成のロジックをここに追加
                  } else {
                    // バリデーションが失敗した場合
                    // エラーメッセージが表示されます
                  }
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
