import 'package:flutter/material.dart';
import 'package:bias_profile/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late Future<DocumentSnapshot<Map<String, dynamic>>> _documentSnapshot;
  List<String> userNames = [];

  @override
  void initState() {
    super.initState();
    _documentSnapshot =
        FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).get();
  }

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
                        FutureBuilder<DocumentSnapshot>(
                            future: _documentSnapshot,
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
                        Text(
                            'https://hogehogehoge.com/?room_id=${widget.roomId}'),
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
