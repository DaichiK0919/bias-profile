import 'package:flutter/material.dart';
import 'package:bias_profile/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class RoomView extends StatefulWidget {
  final double containerWidth;
  final String roomId;

  const RoomView({
    super.key,
    required this.containerWidth,
    required this.roomId,
  });

  @override
  State<RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _documentSnapshot;

  @override
  void initState() {
    super.initState();
    _documentSnapshot = FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .snapshots();
  }

  Future<void> _startRoom() async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .update({
      'status': 'preparing',
      'current_turn.turn_count': 1,
      'current_turn.updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _closeRoom() async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .update({
      'status': 'closed',
      'current_turn.updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _showStartConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // ダイアログ外をタップしても閉じないようにする
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('応募を締め切りますか'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('閉じる'),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                await _startRoom(); // Roomのstatusをin_progressに更新 current_turn.turn_countを1に更新
                Navigator.of(context).pop(); // ダイアログを閉じる
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ゲームが開始されます'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCloseConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // ダイアログ外をタップしても閉じないようにする
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('本当にキャンセルしますか？'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('閉じる'),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                await _closeRoom(); // Roomのstatusをcloseに更新
                Navigator.popUntil(
                    context, ModalRoute.withName('/')); // ダイアログを閉じる
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('部屋の作成をキャンセルしました'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    final String url = 'https://hogehogehoge.com/?room_id=${widget.roomId}';
    return Center(
      child: Container(
        width: widget.containerWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: kMarginLarge),
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
                        StreamBuilder<DocumentSnapshot>(
                            stream: _documentSnapshot,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else {
                                final data = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                final players =
                                    data['players'] as List<dynamic>;
                                return Column(
                                  children: players.map((player) {
                                    return Card(
                                      child: Container(
                                        width: double.infinity,
                                        height: 36.0,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0), // 左右に少し余裕を持たせる
                                        child: Text(
                                          player['nickname'],
                                          textAlign: TextAlign
                                              .center, // Text自体も中央揃えにする
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                            }),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: kMarginLarge),
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
                          'URL',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(url),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: url));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('URLがクリップボードにコピーされました'),
                                ),
                              );
                            },
                            child: Text('コピー'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(kPaddingMedium),
              child: ElevatedButton(
                onPressed: () async {
                  _showStartConfirmationDialog(context);
                },
                child: Text('締め切る'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(kPaddingMedium),
              child: ElevatedButton(
                onPressed: () {
                  _showCloseConfirmationDialog(context);
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
