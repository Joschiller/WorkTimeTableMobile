import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_day_setting.dart';

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
        dayOfWeek:
            DayOfWeek.values.firstWhere((e) => e.name == json['dayOfWeek']),
        timeEquivalent: json['timeEquivalent'],
        mandatoryWorkTimeStart: json['mandatoryWorkTimeStart'],
        mandatoryWorkTimeEnd: json['mandatoryWorkTimeEnd'],
        defaultWorkTimeStart: json['defaultWorkTimeStart'],
        defaultWorkTimeEnd: json['defaultWorkTimeEnd'],
        defaultBreakDuration: json['defaultBreakDuration'],
      );

  factory WeekDaySettingDto.fromAppModel(WeekDaySetting model) =>
      WeekDaySettingDto(
        dayOfWeek: model.dayOfWeek,
        timeEquivalent: model.timeEquivalent,
        mandatoryWorkTimeStart: model.mandatoryWorkTimeStart,
        mandatoryWorkTimeEnd: model.mandatoryWorkTimeEnd,
        defaultWorkTimeStart: model.defaultWorkTimeStart,
        defaultWorkTimeEnd: model.defaultWorkTimeEnd,
        defaultBreakDuration: model.defaultBreakDuration,
      );

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek.name,
        'timeEquivalent': timeEquivalent,
        'mandatoryWorkTimeStart': mandatoryWorkTimeStart,
        'mandatoryWorkTimeEnd': mandatoryWorkTimeEnd,
        'defaultWorkTimeStart': defaultWorkTimeStart,
        'defaultWorkTimeEnd': defaultWorkTimeEnd,
        'defaultBreakDuration': defaultBreakDuration,
      };

  WeekDaySetting toAppModel() => WeekDaySetting(
        dayOfWeek: dayOfWeek,
        timeEquivalent: timeEquivalent,
        mandatoryWorkTimeStart: mandatoryWorkTimeStart,
        mandatoryWorkTimeEnd: mandatoryWorkTimeEnd,
        defaultWorkTimeStart: defaultWorkTimeStart,
        defaultWorkTimeEnd: defaultWorkTimeEnd,
        defaultBreakDuration: defaultBreakDuration,
      );
}
