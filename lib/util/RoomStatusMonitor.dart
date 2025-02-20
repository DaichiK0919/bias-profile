import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bias_profile/components/components.dart';
import './util.dart';
import 'package:bias_profile/Pages/RoomInProgressPage.dart';
import 'package:bias_profile/Pages/ProfileAnswerPage.dart';
import 'package:bias_profile/commons/constants.dart';

mixin RoomStatusMonitor<T extends StatefulWidget> on State<T> {
  late Stream<DocumentSnapshot>? _roomStream;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _roomStreamAsMap;
  bool _hasShownCancelMessage = false;
  int? _lastTurnCount;
  int? _lastParentAnswer; // 前回の親の回答を保持

  void startRoomStatusMonitoring(
    String roomId,
    String playerId, {
    bool isCreator = false,
    bool skipProfileNavigation = false, // ProfileAnswerPage上での監視時はtrueを設定
  }) {
    _roomStream = getRoomSnapshotAsStream(roomId);
    _roomStreamAsMap = getRoomSnapshotAsStream(roomId)
        as Stream<DocumentSnapshot<Map<String, dynamic>>>;

    _roomStream?.listen((snapshot) async {
      if (!mounted) return;
      final data = snapshot.data() as Map<String, dynamic>?;

      if (data == null) return;

      final currentTurn = data['current_turn'] as Map<String, dynamic>;
      final currentTurnCount = currentTurn['turn_count'] as int? ?? 0;
      final parentAnswer = currentTurn['parent_answer'] as int?;
      final parentPlayerId = currentTurn['parent_player_id'] as String?;

      // 親プレイヤー以外に対して、parent_answerが更新されたときにダイアログを表示
      if (parentAnswer != null &&
          parentAnswer != _lastParentAnswer &&
          playerId != parentPlayerId) {
        _lastParentAnswer = parentAnswer;

        // 既存のダイアログをすべて閉じる
        Navigator.of(context).popUntil((route) => route.isCurrent);

        // 少し遅延を入れてから親の回答ダイアログを表示
        Future.delayed(const Duration(milliseconds: 100), () {
          final characterCards =
              List<Map<String, dynamic>>.from(currentTurn['character_cards']);
          final selectedCard = characterCards[parentAnswer];

          showConfirmationDialog(
            context: context,
            title: '親が選択した人物',
            content: Image.network(
              selectedCard['character_card_path'],
              width: ProfileConstants.imageWidth,
              height: ProfileConstants.imageHeight,
              fit: BoxFit.contain,
            ),
            confirmButtonText: '次に進む',
            onConfirm: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    const ProgressDialog(titleText: 'ターンを開始する準備をしています。'),
              );
              await getRoomRef(roomId)
                  .update({'current_turn.can_start_next_turn': true});
            },
          );
        });
      }

      switch (data['status']) {
        case 'closed' when !isCreator && !_hasShownCancelMessage:
          print('部屋のステータスが closed になったのを検知');
          _hasShownCancelMessage = true;
          showConfirmationDialog(
              context: context,
              title: '部屋作成者が募集をキャンセルしました。',
              onConfirm: () async {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              });
          break;

        case _
            when _lastTurnCount != null && currentTurnCount > _lastTurnCount!:
          print('lastTurnCount:$_lastTurnCount');
          print('currentTurnCount:$currentTurnCount');
          print('ターン数の増加を検知');
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                ProgressDialog(titleText: 'ターンを開始する準備をしています。'),
          );
          await Future.delayed(
              Duration(seconds: AppDurations.processingDuration));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RoomInProgressPage(
                roomId: roomId,
                playerId: playerId,
                stream: _roomStreamAsMap,
              ),
            ),
          );
          break;

        case _
            when !skipProfileNavigation && // ProfileAnswerPage上ではスキップ
                currentTurn['profiles'] != null &&
                currentTurn['parent_answer'] == null:
          final profiles =
              List<Map<String, dynamic>>.from(currentTurn['profiles']);

          if (profiles.isEmpty) {
            break;
          }

          final allProfilesCompleted = profiles.every((profile) =>
              profile.containsKey('input_profile') &&
              profile['input_profile'] != null);

          final myProfile = profiles.firstWhere(
            (profile) => profile['assigned_player_id'] == playerId,
            orElse: () => {'input_profile': null},
          );

          if (allProfilesCompleted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileAnswerPage(
                  roomId: roomId,
                  playerId: playerId,
                  stream: _roomStreamAsMap,
                ),
              ),
            );
          }
          break;
      }

      _lastTurnCount = currentTurnCount;
      print('保存されたlastTurnCount:$_lastTurnCount');
    });
  }

  @override
  void dispose() {
    _roomStream = null;
    _lastTurnCount = null;
    _lastParentAnswer = null; // 追加
    super.dispose();
  }
}
