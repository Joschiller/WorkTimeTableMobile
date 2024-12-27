import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/models/value/day_mode.dart';

class DayModeSelector extends StatelessWidget {
  const DayModeSelector({
    super.key,
    required this.dayMode,
    required this.onChange,
  });

  final DayMode dayMode;

  final void Function(DayMode dayMode)? onChange;

  @override
  Widget build(BuildContext context) => DropdownButton<String>(
        value: dayMode != DayMode.nonWorkDay ? dayMode.name : null,
        hint: Text(dayMode.displayValue),
        onChanged: onChange != null
            ? (String? value) => onChange?.call(
                DayMode.values.firstWhere((element) => element.name == value))
            : null,
        items: DayMode.values
            .where((element) => element != DayMode.nonWorkDay)
            .map<DropdownMenuItem<String>>((value) => DropdownMenuItem<String>(
                  value: value.name,
                  child: Text(value.displayValue),
                ))
            .toList(),
      );
}
