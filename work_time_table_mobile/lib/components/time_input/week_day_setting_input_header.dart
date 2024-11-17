import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/time_input/header_row.dart';

class WeekDaySettingInputHeader extends StatelessWidget {
  const WeekDaySettingInputHeader({super.key});

  @override
  Widget build(BuildContext context) => const HeaderRow(
        headers: {
          'Hour equivalent': '',
          'Mandatory work time': '',
          'Usual work time': '',
          'Usual break duration': '',
        },
      );
}
