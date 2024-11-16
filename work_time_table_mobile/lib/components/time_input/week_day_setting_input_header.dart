import 'package:flutter/material.dart';

class WeekDaySettingInputHeader extends StatelessWidget {
  const WeekDaySettingInputHeader({super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          'Hour equivalent',
          'Mandatory work time',
          'Usual work time',
          'Usual break duration',
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
