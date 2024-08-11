import 'package:flutter/material.dart';
import 'package:bias_profile/components/components.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('偏見プロフィール'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return NicknameForm(
                containerWidth: 300,
              );
            } else if (constraints.maxWidth < 1024) {
              return NicknameForm(
                containerWidth: 500,
              );
            } else {
              return NicknameForm(
                containerWidth: 500,
              );
            }
          },
        ));
  }
}
