import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';

class WeekDaySetting {
  final DayOfWeek dayOfWeek;

  final int? defaultWorkTimeStart;
  final int? defaultWorkTimeEnd;
  final int? mandatoryWorkTimeStart;
  final int? mandatoryWorkTimeEnd;
  final int? defaultBreakDuration;

  final int timeEquivalent;

  WeekDaySetting({
    required this.dayOfWeek,
    required this.defaultWorkTimeStart,
    required this.defaultWorkTimeEnd,
    required this.mandatoryWorkTimeStart,
    required this.mandatoryWorkTimeEnd,
    required this.defaultBreakDuration,
    required this.timeEquivalent,
  });
}
