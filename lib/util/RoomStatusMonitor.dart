import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bias_profile/components/components.dart';
import './util.dart';
import 'package:bias_profile/Pages/RoomInProgressPage.dart';

mixin RoomStatusMonitor<T extends StatefulWidget> on State<T> {
  Stream<DocumentSnapshot>? _roomStream;
  bool _hasShownCancelMessage = false;

  void startRoomStatusMonitoring(
      String roomId, bool isCreator, String playerId) {
    _roomStream = getRoomRef(roomId).snapshots();

    _roomStream?.listen((snapshot) async {
      if (!mounted) return;

      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) return;

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

        case _ when data['current_turn']['turn_count'] == 1:
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                ProgressDialog(titleText: 'ターンを開始する準備をしています。'),
          );
          await Future.delayed(Duration(seconds: 3));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RoomInProgressPage(
                roomId: roomId,
                playerId: playerId,
              ),
            ),
          );
          break;
      }
    });
  }

  @override
  void dispose() {
    _roomStream = null;
    super.dispose();
  }
}
