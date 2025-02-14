import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String? content; // 追加
  final String cancelButtonText;
  final String confirmButtonText;
  final VoidCallback? onCancel;
  final Future<void> Function()? onConfirm;
  final Widget? progressDialog;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    this.content, // 追加
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
      content: content != null ? Text(content!) : null, // 追加
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
}

Future<void> showConfirmationDialog({
  required BuildContext context,
  required String title,
  String? content,
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
