import 'package:work_time_table_mobile/dto/day_value_dto.dart';
import 'package:work_time_table_mobile/dto/event_setting_dto.dart';
import 'package:work_time_table_mobile/dto/global_settings_dto.dart';
import 'package:work_time_table_mobile/dto/week_setting_dto.dart';
import 'package:work_time_table_mobile/dto/week_value_dto.dart';

class UserDto {
  final String name;

  final WeekSettingDto weekSettings;
  final List<EventSettingDto> eventSettings;
  final GlobalSettingsDto globalSettings;

  final List<DayValueDto> dayValues;
  final List<WeekValueDto> weekValues;

  UserDto({
    required this.name,
    required this.weekSettings,
    required this.eventSettings,
    required this.globalSettings,
    required this.dayValues,
    required this.weekValues,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        name: json['name'],
        weekSettings: WeekSettingDto.fromJson(json['weekSettings']),
        eventSettings: (json['eventSettings'] as List<Map<String, dynamic>>)
            .map(EventSettingDto.fromJson)
            .toList(),
        globalSettings: GlobalSettingsDto.fromJson(json['globalSettings']),
        dayValues: (json['dayValues'] as List<Map<String, dynamic>>)
            .map(DayValueDto.fromJson)
            .toList(),
        weekValues: (json['weekValues'] as List<Map<String, dynamic>>)
            .map(WeekValueDto.fromJson)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'weekSettings': weekSettings.toJson(),
        'eventSettings': eventSettings.map((e) => e.toJson()),
        'globalSettings': globalSettings.toJson(),
        'dayValues': dayValues.map((e) => e.toJson()),
        'weekValues': weekValues.map((e) => e.toJson()),
      };
}
