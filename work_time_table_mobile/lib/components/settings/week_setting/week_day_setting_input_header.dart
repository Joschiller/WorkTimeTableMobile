import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/settings/week_setting/header_row.dart';

class WeekDaySettingInputHeader extends StatelessWidget {
  const WeekDaySettingInputHeader({super.key});

  @override
  Widget build(BuildContext context) => const HeaderRow(
        headers: {
          'Hour equivalent':
              'This value represents the number of hours, that the day of work is worth. For this value to be actually accounted for, the day must be marked as a "work day". In case of having a day off (e.g. due to illness or vacation) this value will be subtracted from the target work time of that week.\n\nE.g. if the week is worth 39 hours and a day is worth 8 hours, there will be 31 hours left, if the given day is marked as a day off. If all days of the week are marked as a day off, the remaining target work time will be 0 hours.',
          'Mandatory work time':
              'This timespan describes the required hours of the day, that the work time must include.\n\nE.g. if the mandatory work time ends at 17:00, the work time must end earliest at 17:00.',
          'Usual work time':
              'This value will be used as the default whenever a new week is opened in the time input.',
          'Usual break duration':
              'This value will be used as the default whenever a new week is opened in the time input.',
        },
      );
}
