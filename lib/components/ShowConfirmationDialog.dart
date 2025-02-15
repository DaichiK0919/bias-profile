import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final dynamic content; // String または Widget を受け付けるように変更
  final String cancelButtonText;
  final String confirmButtonText;
  final VoidCallback? onCancel;
  final Future<void> Function()? onConfirm;
  final Widget? progressDialog;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    this.content,
    this.cancelButtonText = '閉じる',
    this.confirmButtonText = 'OK',
    this.onCancel,
    this.onConfirm,
    this.progressDialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: _buildContent(), // contentの構築を別メソッドに分離
      actions: <Widget>[
        if (onCancel != null)
          TextButton(
            child: Text(cancelButtonText),
            onPressed: () {
              onCancel?.call();
              Navigator.of(context).pop();
            },
          ),
        TextButton(
          child: Text(confirmButtonText),
          onPressed: onConfirm == null
              ? () {
                  Navigator.of(context).pop();
                }
              : () async {
                  await onConfirm!();
                  if (progressDialog != null) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => progressDialog!,
                    );
                  }
                },
        ),
      ],
    );
  }

  Widget? _buildContent() {
    if (content == null) {
      return null;
    }
    if (content is String) {
      return Text(content as String);
    }
    if (content is Widget) {
      return content as Widget;
    }
    return null;
  }
}

Future<void> showConfirmationDialog({
  required BuildContext context,
  required String title,
  dynamic content, // String または Widget を受け付けるように変更
  String cancelButtonText = '閉じる',
  String confirmButtonText = 'OK',
  VoidCallback? onCancel,
  Future<void> Function()? onConfirm,
  Widget? progressDialog,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => ConfirmationDialog(
      title: title,
      content: content,
      cancelButtonText: cancelButtonText,
      confirmButtonText: confirmButtonText,
      onCancel: onCancel,
      onConfirm: onConfirm,
      progressDialog: progressDialog,
    ),
  );
}
