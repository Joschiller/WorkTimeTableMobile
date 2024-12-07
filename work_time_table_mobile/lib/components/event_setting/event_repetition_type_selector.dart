import 'package:flutter/material.dart';

class EventRepetitionTypeSelector extends StatelessWidget {
  const EventRepetitionTypeSelector({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onSelect,
    this.detailInput,
  });

  final String title;
  final String value;
  final String groupValue;
  final void Function(String newValue) onSelect;
  final Widget? detailInput;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            flex: 1,
            child: RadioListTile(
              title: Text(title),
              value: value,
              groupValue: groupValue,
              onChanged: (newValue) {
                if (newValue == value) onSelect(value);
              },
            ),
          ),
          detailInput != null
              ? Expanded(
                  flex: 3,
                  child: IgnorePointer(
                    ignoring: groupValue != value,
                    child: detailInput!,
                  ),
                )
              : const Spacer(flex: 3),
        ],
      );
}
