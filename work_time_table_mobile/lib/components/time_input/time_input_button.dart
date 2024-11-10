import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/utils.dart';

class TimeInputButton extends StatelessWidget {
  const TimeInputButton({
    super.key,
    this.initialValue,
    this.min,
    this.max,
    required this.onChange,
  });

  final TimeOfDay? initialValue;
  final TimeOfDay? min;
  final TimeOfDay? max;
  final void Function(TimeOfDay value) onChange;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: () => showTimePicker(
          context: context,
          initialTime: initialValue ?? const TimeOfDay(hour: 12, minute: 0),
        ).then((value) {
          if (value != null) {
            onChange(min != null && value.toInt() < min!.toInt()
                ? min!
                : max != null && value.toInt() > max!.toInt()
                    ? max!
                    : value);
          }
        }),
        child: Text(initialValue?.format(context) ?? 'Select Time'),
      );
}
