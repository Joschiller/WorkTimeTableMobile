import 'package:work_time_table_mobile/dto/day_value_dto.dart';
import 'package:work_time_table_mobile/dto/event_setting_dto.dart';
import 'package:work_time_table_mobile/dto/global_settings_dto.dart';
import 'package:work_time_table_mobile/dto/week_setting_dto.dart';
import 'package:work_time_table_mobile/dto/week_value_dto.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/settings_map.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';

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

  factory UserDto.fromAppModel(
    User user,
    WeekSetting weekSetting,
    List<EventSetting> eventSettings,
    SettingsMap globalSettings,
    List<DayValue> dayValues,
    List<WeekValue> weekValues,
  ) =>
      UserDto(
        name: user.name,
        weekSettings: WeekSettingDto.fromAppModel(weekSetting),
        eventSettings: eventSettings.map(EventSettingDto.fromAppModel).toList(),
        globalSettings: GlobalSettingsDto(
          settings: globalSettings,
        ),
        dayValues: dayValues.map(DayValueDto.fromAppModel).toList(),
        weekValues: weekValues.map(WeekValueDto.fromAppModel).toList(),
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
