import 'package:flutter/material.dart';
import 'package:bias_profile/components/components.dart';

class RoomViewPage extends StatelessWidget {
  final List<String> users = const [];
  final String nickname;
  final String roomId;

  const RoomViewPage({super.key, required this.nickname, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('部屋'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return RoomView(
              containerWidth: 300,
              userNames: users,
              nickname: nickname,
              roomId: roomId,
            );
          } else if (constraints.maxWidth < 1024) {
            return RoomView(
              containerWidth: 500,
              userNames: users,
              nickname: nickname,
              roomId: roomId,
            );
          } else {
            return RoomView(
              containerWidth: 500,
              userNames: users,
              nickname: nickname,
              roomId: roomId,
            );
          }
        },
      ),
    );
  }
}
