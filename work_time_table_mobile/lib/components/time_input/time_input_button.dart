import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/utils.dart';

class TimeInputButton extends StatelessWidget {
  const TimeInputButton({
    super.key,
    this.value,
    TimeOfDay? min,
    TimeOfDay? max,
    required this.onChange,
  })  : min = min ?? const TimeOfDay(hour: 0, minute: 0),
        max = max ?? const TimeOfDay(hour: 23, minute: 59);

  final TimeOfDay? value;
  final TimeOfDay min;
  final TimeOfDay max;
  final void Function(TimeOfDay value)? onChange;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onChange != null
            ? () => showTimePicker(
                  context: context,
                  initialTime: value ?? const TimeOfDay(hour: 12, minute: 0),
                ).then((value) {
                  if (value != null) {
                    onChange?.call(value.toInt() < min.toInt()
                        ? min
                        : value.toInt() > max.toInt()
                            ? max
                            : value);
                  }
                })
            : null,
        child:
            Text(value != null ? '${value!.format(context)} h' : 'Select Time'),
      );
}
