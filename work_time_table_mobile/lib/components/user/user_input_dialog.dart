import 'package:flutter/material.dart';
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
  var _addButtonEnabled = false;

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
    setState(() => _addButtonEnabled = UserService.isUserValid(
          _textEditingController.text,
          widget.occupiedNames,
        ));
  }

  void _onConfirm() {
    widget.onConfirm(_textEditingController.text.trim());
    _textEditingController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => ConfirmableAlertDialog(
        title: widget.dialogTitle,
        content: TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter a name',
          ),
          controller: _textEditingController,
        ),
        actionText: widget.actionText,
        onCancel: Navigator.of(context).pop,
        onConfirm: _addButtonEnabled ? _onConfirm : null,
      );
}
