import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/time_input/header_row.dart';

class GlobalWeekDaySettingInputHeader extends StatelessWidget {
  const GlobalWeekDaySettingInputHeader({super.key});

  @override
  Widget build(BuildContext context) => const Row(
        children: [
          Expanded(
            child: HeaderRow(
              headers: {
                'Target work time per week': '',
              },
            ),
          ),
          Spacer(flex: 3),
        ],
      );
}
