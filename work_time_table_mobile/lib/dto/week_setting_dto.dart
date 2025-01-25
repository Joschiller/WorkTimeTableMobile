import 'package:work_time_table_mobile/dto/week_day_setting_dto.dart';

class WeekSettingDto {
  final int targetWorkTimePerWeek;
  final List<WeekDaySettingDto> weekDaySettings;

  WeekSettingDto({
    required this.targetWorkTimePerWeek,
    required this.weekDaySettings,
  });

  factory WeekSettingDto.fromJson(Map<String, dynamic> json) => WeekSettingDto(
        targetWorkTimePerWeek: json['targetWorkTimePerWeek'],
        weekDaySettings: (json['weekDaySettings'] as List<Map<String, dynamic>>)
            .map(WeekDaySettingDto.fromJson)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'targetWorkTimePerWeek': targetWorkTimePerWeek,
        'weekDaySettings': weekDaySettings.map((e) => e.toJson()),
      };
}
