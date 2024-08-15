import 'package:flutter/material.dart';
import 'package:bias_profile/constants.dart';

class RoomView extends StatelessWidget {
  final double containerWidth;
  final List<String> userNames;
  final String nickname;

  const RoomView({
    super.key,
    required this.containerWidth,
    required this.userNames,
    required this.nickname,
  });

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
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(16.0), // 角を丸くする
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(kPaddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '参加メンバー',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Column(
                          children: userNames.map((name) {
                            return Card(
                              child: Container(
                                width: double.infinity,
                                height: 36.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0), // 左右に少し余裕を持たせる
                                child: Text(
                                  name,
                                  textAlign: TextAlign.center, // Text自体も中央揃えにする
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        Card(
                          child: Container(
                            width: double.infinity,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            alignment: Alignment.centerLeft, // これがポイント！
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0), // 左右に少し余裕を持たせる
                            child: Text(
                              nickname,
                              textAlign: TextAlign.center, // Text自体も中央揃えにする
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(kPaddingLarge),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '部屋リンク',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text('部屋リンクURLを表示'),
                      ],
                    ),
                  ),
                ),
              ],
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
