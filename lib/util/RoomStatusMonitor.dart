import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bias_profile/components/components.dart';
import './util.dart';
import 'package:bias_profile/Pages/RoomInProgressPage.dart';
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
      final currentTurnCount = currentTurn['turn_count'] as int;

      switch (data['status']) {
        case 'closed' when !isCreator && !_hasShownCancelMessage:
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
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                ProgressDialog(titleText: 'ターンを開始する準備をしています。'),
          );
          await Future.delayed(Duration(seconds: kProcessingDuration));
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
      }

      // 現在のターン数を保存
      _lastTurnCount = currentTurnCount;
    });
  }

  @override
  void dispose() {
    _roomStream = null;
    _lastTurnCount = null; // リセット
    super.dispose();
  }
}
