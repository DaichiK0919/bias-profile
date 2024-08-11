import 'package:flutter/material.dart';
import 'package:bias_profile/components/components.dart';

class RoomViewPage extends StatelessWidget {
  const RoomViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return RoomView(
            containerWidth: 300,
          );
        } else if (constraints.maxWidth < 1024) {
          return RoomView(
            containerWidth: 500,
          );
        } else {
          return RoomView(
            containerWidth: 500,
          );
        }
      },
    ));
  }
}
