import 'package:flutter/material.dart';
import 'package:bias_profile/components/components.dart';
import 'package:bias_profile/commons/ResponsiveLayout.dart';

class RoomViewPage extends StatelessWidget {
  final String roomId;
  final String playerId;
  final bool isCreator;

  const RoomViewPage(
      {super.key,
      required this.roomId,
      required this.playerId,
      required this.isCreator});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isCreator ? Text('参加募集中') : Text('参加待ち・・・'),
        automaticallyImplyLeading: false,
      ),
      body: ResponsiveLayout(
        breakPoints: [
          BreakPoint(minWidth: 1024, containerWidth: 500),
          BreakPoint(minWidth: 600, containerWidth: 500),
          BreakPoint(minWidth: 0, containerWidth: 300),
        ],
        builder: (context, containerWidth) {
          return RoomViewForm(
            containerWidth: containerWidth,
            roomId: roomId,
            playerId: playerId,
            isCreator: isCreator,
          );
        },
      ),
    );
  }
}
