import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String cancelButtonText;
  final String confirmButtonText;
  final VoidCallback? onCancel;
  final Future<void> Function()? onConfirm;
  final Widget? progressDialog;

  const ConfirmationDialog({
    Key? key,
    required this.title,
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
      actions: <Widget>[
        if (onCancel != null) // nullでない場合のみボタンを表示
          TextButton(
            child: Text(cancelButtonText),
            onPressed: () {
              onCancel?.call(); // null安全な呼び出し
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
      cancelButtonText: cancelButtonText,
      confirmButtonText: confirmButtonText,
      onCancel: onCancel,
      onConfirm: onConfirm,
      progressDialog: progressDialog,
    ),
  );
}
