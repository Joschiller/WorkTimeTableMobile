import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/week_setting/header_row.dart';

class GlobalWeekDaySettingInputHeader extends StatelessWidget {
  const GlobalWeekDaySettingInputHeader({super.key});

  @override
  Widget build(BuildContext context) => const Row(
        children: [
          Expanded(
            child: HeaderRow(
              headers: {
                'Target work time per week':
                    'This value represents the weekly number of working hours. This value cannot exceed the sum of all working hours per day.\n\nE.g. each day of work can be worth 8 hours, whilst the overall week is worth 39 hours at max.',
              },
            ),
          ),
          Spacer(flex: 3),
        ],
      );
}
