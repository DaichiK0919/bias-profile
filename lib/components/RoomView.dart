import 'package:flutter/material.dart';
import 'package:bias_profile/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:bias_profile/components/components.dart';

class RoomView extends StatefulWidget {
  final double containerWidth;
  final String roomId;
  final String playerId;

  const RoomView({
    super.key,
    required this.containerWidth,
    required this.roomId,
    required this.playerId,
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

  DocumentReference getRoomRef(String roomId) {
    return FirebaseFirestore.instance.collection('rooms').doc(roomId);
  }

  Future<Map<String, dynamic>> getRoomSnapshot(String roomId) async {
    DocumentSnapshot roomSnapshot = await getRoomRef(roomId).get();

    if (!roomSnapshot.exists) {
      throw Exception('Room not found');
    }
    return roomSnapshot.data() as Map<String, dynamic>;
  }

  // 現状使ってない関数　UUIDでplayerを探す
  // Future<Map<String, dynamic>?> findPlayerByUUID(
  //     String roomId, String playerId) async {
  //   Map<String, dynamic> roomData = await getRoomSnapshot(roomId);
  //
  //   // プレイヤーリストを取得
  //   List<dynamic> players = roomData['players'];
  //
  //   // UUIDで特定のプレイヤーを見つける
  //   return players.firstWhere((player) => player['player_id'] == playerId,
  //       orElse: () => null);
  // }

  Future<void> startRoom(String roomId, String playerId) async {
    DocumentReference roomRef = getRoomRef(roomId);
    Map<String, dynamic> roomData = await getRoomSnapshot(roomId);
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
                  showConfirmationDialog(
                      context: context,
                      title: '募集を締め切りますか？',
                      confirmButtonText: '締め切る',
                      onCancel: () {},
                      onConfirm: () async {
                        await startRoom(widget.roomId, widget.playerId);
                      },
                      progressDialog:
                          ProgressDialog(titleText: 'ターンを開始する準備をしています。'));
                },
                child: Text('締め切る'),
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}
