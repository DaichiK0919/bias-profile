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
  int? _lastTurnCount; // 前回のターン数を保持

  void startRoomStatusMonitoring(
    String roomId,
    String playerId, {
    bool isCreator = false,
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

        // プロフィール入力の監視を追加
        case _
            when currentTurn['profiles'] != null &&
                currentTurn['parent_answer'] == null:
          final profiles =
              List<Map<String, dynamic>>.from(currentTurn['profiles']);

          if (profiles.isEmpty) {
            break; // 空の場合は何もしない
          }

          final allProfilesCompleted = profiles.every((profile) =>
              profile.containsKey('input_profile') &&
              profile['input_profile'] != null);

          // 自分の入力状態を確認
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

      // 現在のターン数を保存
      _lastTurnCount = currentTurnCount;
      print('保存されたlastTurnCount:$_lastTurnCount');
    });
  }

  @override
  void dispose() {
    _roomStream = null;
    _lastTurnCount = null; // リセット
    super.dispose();
  }
}
