import 'package:flutter/material.dart';
import 'package:bias_profile/components/components.dart';

class RoomViewPage extends StatelessWidget {
  final String roomId;
  final String playerId;

  const RoomViewPage({super.key, required this.roomId, required this.playerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('部屋'),
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return RoomView(
              containerWidth: 300,
              roomId: roomId,
              playerId: playerId,
            );
          } else if (constraints.maxWidth < 1024) {
            return RoomView(
              containerWidth: 500,
              roomId: roomId,
              playerId: playerId,
            );
          } else {
            return RoomView(
              containerWidth: 500,
              roomId: roomId,
              playerId: playerId,
            );
          }
        },
      ),
    );
  }
}
