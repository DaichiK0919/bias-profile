import 'package:bias_profile/Pages/CreateandJoinRoomPage.dart';
import 'package:flutter/material.dart';
import 'package:bias_profile/commons/ResponsiveLayout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        breakPoints: [
          BreakPoint(minWidth: 1024, containerWidth: 500),
          BreakPoint(minWidth: 600, containerWidth: 500),
          BreakPoint(minWidth: 0, containerWidth: 300),
        ],
        builder: (context, containerWidth) {
          return CreateandJoinRoomPage(containerWidth: containerWidth);
        },
      ),
    );
  }
}
