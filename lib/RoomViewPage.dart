import 'package:flutter/material.dart';
import 'package:bias_profile/components/components.dart';

class RoomViewPage extends StatelessWidget {
  final List<String> Users = const ['ひろと', 'ひろや', 'なおゆき', 'だいち'];

  const RoomViewPage({super.key});

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
            );
          } else if (constraints.maxWidth < 1024) {
            return RoomView(
              containerWidth: 500,
              userNames: Users,
            );
          } else {
            return RoomView(
              containerWidth: 500,
              userNames: Users,
            );
          }
        },
      ),
    );
  }
}
