import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/models/statistics/statistics_mode.dart';

class StatisticsModeSelector extends StatelessWidget {
  const StatisticsModeSelector({
    super.key,
    required this.statisticsMode,
    required this.onChange,
  });

  final StatisticsMode statisticsMode;

  final void Function(StatisticsMode statisticsMode) onChange;

  @override
  Widget build(BuildContext context) => DropdownButton<String>(
        value: statisticsMode.name,
        onChanged: (String? value) => onChange(StatisticsMode.values
            .firstWhere((element) => element.name == value)),
        items: StatisticsMode.values
            .map<DropdownMenuItem<String>>((value) => DropdownMenuItem<String>(
                  value: value.name,
                  child: Text(value.displayValue),
                ))
            .toList(),
      );
}
