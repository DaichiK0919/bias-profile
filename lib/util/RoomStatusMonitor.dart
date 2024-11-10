import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bias_profile/components/components.dart';
import './util.dart';
import 'package:bias_profile/Pages/RoomInProgressPage.dart';

// Mixinとして実装することで、必要な画面で再利用可能にする
mixin RoomStatusMonitor<T extends StatefulWidget> on State<T> {
  Stream<DocumentSnapshot>? _roomStream;
  bool _hasShownCancelMessage = false;

  void startRoomStatusMonitoring(
      String roomId, bool isCreator, String playerId) {
    _roomStream = getRoomRef(roomId).snapshots();

    _roomStream?.listen((snapshot) async {
      if (!mounted) return;

      final data = snapshot.data() as Map<String, dynamic>?;
      if (data != null &&
          data['status'] == 'closed' &&
          !_hasShownCancelMessage &&
          !isCreator) {
        _hasShownCancelMessage = true;
        showConfirmationDialog(
            context: context,
            title: '部屋作成者が募集をキャンセルしました。',
            onConfirm: () async {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            });
      } else if (data != null && data['current_turn']['turn_count'] == 1) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              ProgressDialog(titleText: 'ターンを開始する準備をしています。'),
        );
        if (context.mounted) {
          await Future.delayed(Duration(seconds: 3));
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RoomInProgressPage(
                roomId: roomId,
                playerId: playerId,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    // Stateが破棄されるときにStreamを解放
    _roomStream = null;
    super.dispose();
  }
}
