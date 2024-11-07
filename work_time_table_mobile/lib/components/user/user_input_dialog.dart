import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/components/confirmable_alert_dialog.dart';
import 'package:work_time_table_mobile/services/user_service.dart';

class UserInputDialog extends StatefulWidget {
  const UserInputDialog({
    super.key,
    required this.dialogTitle,
    required this.actionText,
    required this.initialValue,
    required this.occupiedNames,
    required this.onConfirm,
  });

  final String dialogTitle;
  final String actionText;

  final String initialValue;
  final List<String> occupiedNames;
  final void Function(String name) onConfirm;

  @override
  State<UserInputDialog> createState() => _UserInputDialogState();
}

class _UserInputDialogState extends State<UserInputDialog> {
  final _textEditingController = TextEditingController();
  var _validationErrors = <AppError>[];

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(_validate);
    _textEditingController.text = widget.initialValue;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() => _validationErrors = UserService.getUserNameValidator(
          _textEditingController.text,
          widget.occupiedNames,
        ).validateAll());
  }

  void _onConfirm() {
    widget.onConfirm(_textEditingController.text.trim());
    _textEditingController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => ConfirmableAlertDialog(
        title: widget.dialogTitle,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a name',
              ),
              controller: _textEditingController,
            ),
            for (final v in _validationErrors)
              Text(
                v.displayText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
        actionText: widget.actionText,
        onCancel: Navigator.of(context).pop,
        onConfirm: _validationErrors.isEmpty ? _onConfirm : null,
      );
}
