import 'package:flutter/material.dart';
import 'package:bias_profile/commons/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:bias_profile/components/components.dart';
import 'package:bias_profile/util/util.dart';
import 'package:bias_profile/util/RoomStatusMonitor.dart';
import 'package:bias_profile/Pages/ProfileInputPage.dart';

class RoomInProgressForm extends StatefulWidget {
  final double containerWidth;
  final String roomId;
  final String playerId;
  final Stream<DocumentSnapshot<Map<String, dynamic>>> streamAsMap;
  final String? correctCardPath;
  final List<String> otherCardPaths;
  final String? assignedProfileTheme;

  const RoomInProgressForm({
    super.key,
    required this.containerWidth,
    required this.roomId,
    required this.playerId,
    required this.streamAsMap,
    required this.correctCardPath,
    required this.otherCardPaths,
    required this.assignedProfileTheme,
  });

  @override
  State<RoomInProgressForm> createState() => _RoomInProgressFormState();
}

class _RoomInProgressFormState extends State<RoomInProgressForm>
    with RoomStatusMonitor {
  bool _isImageLoading = true;

  @override
  void initState() {
    super.initState();
    startRoomStatusMonitoring(widget.roomId, widget.playerId);
  }

  // 全ての画像をプリキャッシュする関数
  Future<void> _precacheAllImages() async {
    if (!mounted) return;

    try {
      if (widget.correctCardPath != null) {
        await precacheImage(
          NetworkImage(widget.correctCardPath!),
          context,
        );
      }

      for (final path in widget.otherCardPaths) {
        await precacheImage(
          NetworkImage(path),
          context,
        );
      }
    } catch (e) {
      print('Image precaching error: $e');
    }
  }

  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: widget.containerWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: AppDimensions.marginLarge),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: PlayerList(
                    documentSnapshot: widget.streamAsMap,
                    listTitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '得点表',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: widget.streamAsMap,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    final data = snapshot.data!.data();
                    if (data == null) return Container();

                    final currentTurn =
                        data['current_turn'] as Map<String, dynamic>;
                    final parentPlayerId =
                        currentTurn['parent_player_id'] as String;

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: findPlayerByUUID(widget.roomId, parentPlayerId),
                      builder: (context, playerSnapshot) {
                        if (!playerSnapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        final player = playerSnapshot.data;
                        if (player == null) return Container();

                        return Container(
                          width: double.infinity,
                          margin: EdgeInsets.all(AppDimensions.marginLarge),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'このターンの親は',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              SizedBox(height: AppDimensions.marginLarge),
                              Text(
                                player['nickname'] as String,
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    final data = await getRoomSnapshotAsMap(widget.roomId);
                    final currentTurn =
                        data['current_turn'] as Map<String, dynamic>;
                    final isParent =
                        currentTurn['parent_player_id'] == widget.playerId;

                    if (!mounted) return;

                    if (isParent) {
                      // Parentの場合は全ての画像をプリキャッシュしてダイアログを表示
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => ProgressDialog(
                          titleText: '子のターンです。入力が完了するまでお待ちください。',
                        ),
                      );
                      _precacheAllImages().then((_) {
                        if (!mounted) return;
                        // プリキャッシュ完了後に何か処理が必要な場合はここに記述
                      });
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileInputPage(
                            roomId: widget.roomId,
                            playerId: widget.playerId,
                            stream: widget.streamAsMap,
                            correctCardPath: widget.correctCardPath,
                            otherCardPaths: widget.otherCardPaths,
                            assignedProfileTheme: widget.assignedProfileTheme,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('次に進む'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
