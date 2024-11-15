import 'package:flutter/material.dart';

class GlobalWeekDaySettingInputHeader extends StatelessWidget {
  const GlobalWeekDaySettingInputHeader({super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          'Default work time',
          'Default mandatory work time',
          'Default break duration',
          'Target work time per week',
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
