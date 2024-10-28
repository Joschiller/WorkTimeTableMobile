import 'package:flutter/material.dart';

class ConfirmableAlertDialog extends StatelessWidget {
  const ConfirmableAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actionText,
    this.isActionNegative,
    required this.onCancel,
    this.onConfirm,
  });

  final String title;
  final Widget content;

  final String actionText;
  final bool? isActionNegative;

  final void Function() onCancel;
  final void Function()? onConfirm;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          ElevatedButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: isActionNegative == true
                ? ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(actionText),
          ),
        ],
      );
}
