import 'package:work_time_table_mobile/dto/week_day_setting_dto.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';

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

  factory WeekSettingDto.fromAppModel(WeekSetting model) => WeekSettingDto(
        targetWorkTimePerWeek: model.targetWorkTimePerWeek,
        weekDaySettings: model.weekDaySettings.values
            .map(WeekDaySettingDto.fromAppModel)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'targetWorkTimePerWeek': targetWorkTimePerWeek,
        'weekDaySettings': weekDaySettings,
      };

  WeekSetting toAppModel() => WeekSetting(
        targetWorkTimePerWeek: targetWorkTimePerWeek,
        weekDaySettings: {
          for (final day in weekDaySettings.map((e) => e.toAppModel()))
            day.dayOfWeek: day,
        },
      );
}
