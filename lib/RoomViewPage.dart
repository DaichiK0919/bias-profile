import 'package:flutter/material.dart';
import 'package:bias_profile/components/components.dart';

class RoomViewPage extends StatelessWidget {
  final List<String> Users = const [];
  final String nickname;

  const RoomViewPage({super.key, required this.nickname});

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
              userNames: Users,
              nickname: nickname,
            );
          } else if (constraints.maxWidth < 1024) {
            return RoomView(
              containerWidth: 500,
              userNames: Users,
              nickname: nickname,
            );
          } else {
            return RoomView(
              containerWidth: 500,
              userNames: Users,
              nickname: nickname,
            );
          }
        },
      ),
    );
  }
}
