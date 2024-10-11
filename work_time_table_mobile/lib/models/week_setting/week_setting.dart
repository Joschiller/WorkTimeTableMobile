import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/global_week_day_setting.dart';
import 'package:work_time_table_mobile/models/week_setting/week_day_setting.dart';

class WeekSetting {
  final int targetWorkTimePerWeek;
  final GlobalWeekDaySetting globalWeekDaySetting;

  /// A day is considered to be a work day if a configuration for that day exists.
  final Map<DayOfWeek, WeekDaySetting> weekDaySettings;

  WeekSetting({
    required this.targetWorkTimePerWeek,
    required this.globalWeekDaySetting,
    required this.weekDaySettings,
  });
}
