import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/utils.dart';

class DateInputButton extends StatelessWidget {
  const DateInputButton({
    super.key,
    this.value,
    this.min,
    this.max,
    required this.onChange,
  });

  final DateTime? value;
  final DateTime? min;
  final DateTime? max;
  final void Function(DateTime value) onChange;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: () => showDatePicker(
          context: context,
          firstDate: min ?? DateTime.utc(2020, 1, 1),
          lastDate: max ?? DateTime.utc(DateTime.now().year + 5, 12, 31),
          initialDate: value ?? DateTime.now().toDay(),
        ).then((value) {
          if (value != null) {
            onChange(min != null && value.isBefore(min!)
                ? DateTime.utc(min!.year, min!.month, min!.day)
                : max != null && value.isAfter(max!)
                    ? DateTime.utc(max!.year, max!.month, max!.day)
                    : DateTime.utc(value.year, value.month, value.day));
          }
        }),
        child: Text(
          value != null ? displayDateFormat.format(value!) : 'Select Date',
        ),
      );
}
