import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bias_profile/components/components.dart';
import 'package:bias_profile/commons/ResponsiveLayout.dart';
import 'package:bias_profile/util/util.dart';

class RoomInProgressPage extends StatelessWidget {
  final String roomId;
  final String playerId;

  const RoomInProgressPage({
    super.key,
    required this.roomId,
    required this.playerId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: getRoomSnapshotAsStream(roomId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final documentSnapshot = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: switch (documentSnapshot.get('status')) {
              'in_progress' => Text('プレイヤー一覧'),
              'closed' => Text('最終結果'),
              _ => null,
            },
            automaticallyImplyLeading: false,
          ),
          body: ResponsiveLayout(
            breakPoints: [
              BreakPoint(minWidth: 1024, containerWidth: 500),
              BreakPoint(minWidth: 600, containerWidth: 500),
              BreakPoint(minWidth: 0, containerWidth: 300),
            ],
            builder: (context, containerWidth) {
              return SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
