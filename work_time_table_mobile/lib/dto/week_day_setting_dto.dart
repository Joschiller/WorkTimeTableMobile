import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';

class WeekDaySettingDto {
  final DayOfWeek dayOfWeek;

  final int timeEquivalent;

  final int mandatoryWorkTimeStart;
  final int mandatoryWorkTimeEnd;

  final int defaultWorkTimeStart;
  final int defaultWorkTimeEnd;

  final int defaultBreakDuration;

  WeekDaySettingDto({
    required this.dayOfWeek,
    required this.timeEquivalent,
    required this.mandatoryWorkTimeStart,
    required this.mandatoryWorkTimeEnd,
    required this.defaultWorkTimeStart,
    required this.defaultWorkTimeEnd,
    required this.defaultBreakDuration,
  });

  factory WeekDaySettingDto.fromJson(Map<String, dynamic> json) =>
      WeekDaySettingDto(
        dayOfWeek: json['dayOfWeek'],
        timeEquivalent: json['timeEquivalent'],
        mandatoryWorkTimeStart: json['mandatoryWorkTimeStart'],
        mandatoryWorkTimeEnd: json['mandatoryWorkTimeEnd'],
        defaultWorkTimeStart: json['defaultWorkTimeStart'],
        defaultWorkTimeEnd: json['defaultWorkTimeEnd'],
        defaultBreakDuration: json['defaultBreakDuration'],
      );

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'timeEquivalent': timeEquivalent,
        'mandatoryWorkTimeStart': mandatoryWorkTimeStart,
        'mandatoryWorkTimeEnd': mandatoryWorkTimeEnd,
        'defaultWorkTimeStart': defaultWorkTimeStart,
        'defaultWorkTimeEnd': defaultWorkTimeEnd,
        'defaultBreakDuration': defaultBreakDuration,
      };
}
