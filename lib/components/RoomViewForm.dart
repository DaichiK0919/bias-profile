import 'package:flutter/material.dart';
import 'package:bias_profile/commons/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:bias_profile/components/components.dart';
import 'package:bias_profile/util/util.dart';

class RoomViewForm extends StatefulWidget {
  final double containerWidth;
  final String roomId;
  final String playerId;
  final bool isCreator;

  const RoomViewForm({
    super.key,
    required this.containerWidth,
    required this.roomId,
    required this.playerId,
    required this.isCreator,
  });

  @override
  State<RoomViewForm> createState() => _RoomViewFormState();
}

class _RoomViewFormState extends State<RoomViewForm> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _documentSnapshot;

  @override
  void initState() {
    super.initState();
    _documentSnapshot = FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .snapshots();
  }

  Future<void> startRoom(String roomId, String playerId) async {
    DocumentReference roomRef = getRoomRef(roomId);
    Map<String, dynamic> roomData = await getRoomSnapshotAsMap(roomId);
    List<dynamic> players = roomData['players'];

    int playerIndex =
        players.indexWhere((player) => player['player_id'] == playerId);

    if (playerIndex != -1) {
      players[playerIndex]['can_start_next_turn'] = true;

      await roomRef.update({
        'players': players,
        'current_turn.updated_at': FieldValue.serverTimestamp(),
      });

      print('プレイヤー $playerId のcan_start_next_turnが更新されました。');
    } else {
      print('プレイヤー $playerId が見つかりませんでした。');
    }
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

  Future<void> _leaveRoom(String roomId, String playerId) async {
    try {
      // プレイヤー情報を取得
      Map<String, dynamic>? leavingPlayer =
          await findPlayerByUUID(roomId, playerId);

      if (leavingPlayer != null) {
        // Firestoreのplayersリストからプレイヤーを削除
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomId)
            .update({
          'players': FieldValue.arrayRemove([leavingPlayer]) // プレイヤーをリストから削除
        });

        print('Player left from room $roomId');
      } else {
        print('Player with ID $playerId not found in room $roomId');
      }
    } catch (e) {
      print('Error removing player: $e');
    }
  }

  Widget build(BuildContext context) {
    final String url = 'https://bias-profile.web.app/?room_id=${widget.roomId}';

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
                          '参加者',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          '※最大参加人数は４名',
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
                if (widget.isCreator)
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
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            url,
                            overflow:
                                TextOverflow.ellipsis, // 画面外のテキストを "..." にする
                            softWrap: false, // 改行を無効にする
                            maxLines: 1,
                          ), // 表示する行数を1行に設定),
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
                  )
              ],
            ),
            if (widget.isCreator)
              StreamBuilder<int>(
                stream: getPlayerCountStream(widget.roomId), // 非同期関数
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // ローディング中の表示
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    // エラーハンドリング
                    return Text('エラーが発生しました');
                  } else {
                    // プレイヤーが2人以上かつ部屋の作成者の場合のみボタンを活性化
                    bool isButtonActive =
                        widget.isCreator && (snapshot.data ?? 0) > 1;

                    return Padding(
                      padding: EdgeInsets.all(kPaddingMedium),
                      child: ElevatedButton(
                        onPressed: isButtonActive
                            ? () async {
                                showConfirmationDialog(
                                  context: context,
                                  title: '募集を締め切りますか？',
                                  confirmButtonText: '締め切る',
                                  onCancel: () {},
                                  onConfirm: () async {
                                    await startRoom(
                                        widget.roomId, widget.playerId);
                                  },
                                  progressDialog: ProgressDialog(
                                      titleText: 'ターンを開始する準備をしています。'),
                                );
                              }
                            : null, // 非活性にするためにnull
                        child: Text('締め切る'),
                      ),
                    );
                  }
                },
              ),
            if (widget.isCreator)
              Padding(
                padding: EdgeInsets.all(kPaddingMedium),
                child: ElevatedButton(
                  onPressed: () {
                    showConfirmationDialog(
                        context: context,
                        title: '本当にキャンセルしますか？',
                        onCancel: () {},
                        onConfirm: () async {
                          await _closeRoom();
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('キャンセルが完了しました'),
                            ),
                          );
                        });
                  },
                  child: Text('キャンセル'),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.all(kPaddingMedium),
                child: ElevatedButton(
                  onPressed: () {
                    showConfirmationDialog(
                        context: context,
                        title: '本当にキャンセルしますか？',
                        onCancel: () {},
                        onConfirm: () async {
                          await _leaveRoom(widget.roomId, widget.playerId);
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('キャンセルが完了しました'),
                            ),
                          );
                        });
                  },
                  child: Text('キャンセル'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
