import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';

class WeekDaySetting {
  final DayOfWeek dayOfWeek;

  final int timeEquivalent;

  final int mandatoryWorkTimeStart;
  final int mandatoryWorkTimeEnd;

  final int defaultWorkTimeStart;
  final int defaultWorkTimeEnd;

  final int defaultBreakDuration;

  WeekDaySetting({
    required this.dayOfWeek,
    required this.timeEquivalent,
    required this.mandatoryWorkTimeStart,
    required this.mandatoryWorkTimeEnd,
    required this.defaultWorkTimeStart,
    required this.defaultWorkTimeEnd,
    required this.defaultBreakDuration,
  });

  WeekDaySetting.defaultValue(DayOfWeek dayOfWeek)
      : this(
          dayOfWeek: dayOfWeek,
          timeEquivalent: 0,
          mandatoryWorkTimeStart: 0,
          mandatoryWorkTimeEnd: 0,
          defaultWorkTimeStart: 0,
          defaultWorkTimeEnd: 0,
          defaultBreakDuration: 0,
        );
}
