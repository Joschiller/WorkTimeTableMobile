import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';

class StatisticsState {
  final bool notEnoughDataWarning;

  final List<double> workDaysInWeek;
  final Map<DayOfWeek, List<DayValue>> dayValuesPerDayOfWeek;

  StatisticsState({
    required this.notEnoughDataWarning,
    required this.workDaysInWeek,
    required this.dayValuesPerDayOfWeek,
  });
}
