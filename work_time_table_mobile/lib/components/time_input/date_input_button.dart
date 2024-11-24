import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_time_table_mobile/utils.dart';

final dateFormat = DateFormat('dd.MM.yyyy');

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
          firstDate: min ?? DateTime(2020, 1, 1),
          lastDate: max ?? DateTime(DateTime.now().year + 5, 12, 31),
          initialDate: value ?? DateTime.now().toDay(),
        ).then((value) {
          if (value != null) {
            onChange(min != null && value.isBefore(min!)
                ? min!
                : max != null && value.isAfter(max!)
                    ? max!
                    : value);
          }
        }),
        child: Text(value != null ? dateFormat.format(value!) : 'Select Date'),
      );
}
