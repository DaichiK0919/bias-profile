import 'package:flutter/material.dart';
import 'package:bias_profile/constants.dart';

class ProgressDialog extends StatelessWidget {
  final String titleText;

  const ProgressDialog({
    super.key,
    required this.titleText,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(titleText),
      children: [
        Padding(
          padding: EdgeInsets.all(kPaddingLarge),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
      ],
    );
  }
}
