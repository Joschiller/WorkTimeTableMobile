import 'package:flutter/material.dart';

class WeekDaySettingInputHeader extends StatelessWidget {
  const WeekDaySettingInputHeader({super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          'Usual work time',
          'Mandatory work time',
          'Usual break duration',
          'Hour equivalent',
        ]
            .map((header) => Expanded(
                    child: Center(
                  child: Text(
                    header,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )))
            .toList(),
      );
}
