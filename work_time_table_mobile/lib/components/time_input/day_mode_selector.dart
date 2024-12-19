import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/models/value/day_mode.dart';

class DayModeSelector extends StatelessWidget {
  const DayModeSelector({
    super.key,
    required this.dayMode,
    required this.onChange,
  });

  final DayMode dayMode;

  final void Function(DayMode dayMode) onChange;

  @override
  Widget build(BuildContext context) => DropdownButton<String>(
        value: dayMode.name,
        onChanged: (String? value) => onChange(
            DayMode.values.firstWhere((element) => element.name == value)),
        items: DayMode.values
            .map<DropdownMenuItem<String>>((value) => DropdownMenuItem<String>(
                  value: value.name,
                  child: Text(value.displayValue),
                ))
            .toList(),
      );
}
