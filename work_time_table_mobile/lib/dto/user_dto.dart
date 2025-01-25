import 'package:work_time_table_mobile/dto/day_value_dto.dart';
import 'package:work_time_table_mobile/dto/event_setting_dto.dart';
import 'package:work_time_table_mobile/dto/global_settings_dto.dart';
import 'package:work_time_table_mobile/dto/week_setting_dto.dart';
import 'package:work_time_table_mobile/dto/week_value_dto.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/settings_map.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';

class UserDto {
  final int exportVersion;
  final String name;

  final WeekSettingDto weekSettings;
  final List<EventSettingDto> eventSettings;
  final GlobalSettingsDto globalSettings;

  final List<DayValueDto> dayValues;
  final List<WeekValueDto> weekValues;

  UserDto({
    required this.exportVersion,
    required this.name,
    required this.weekSettings,
    required this.eventSettings,
    required this.globalSettings,
    required this.dayValues,
    required this.weekValues,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        exportVersion: json['exportVersion'],
        name: json['name'],
        weekSettings: WeekSettingDto.fromJson(json['weekSettings']),
        eventSettings: (json['eventSettings'] as List)
            .map((e) => EventSettingDto.fromJson(e))
            .toList(),
        globalSettings: GlobalSettingsDto.fromJson(json['globalSettings']),
        dayValues: (json['dayValues'] as List)
            .map((e) => DayValueDto.fromJson(e))
            .toList(),
        weekValues: (json['weekValues'] as List)
            .map((e) => WeekValueDto.fromJson(e))
            .toList(),
      );

  factory UserDto.fromAppModel(
    int exportVersion,
    String userName,
    WeekSetting weekSetting,
    List<EventSetting> eventSettings,
    SettingsMap globalSettings,
    List<DayValue> dayValues,
    List<WeekValue> weekValues,
  ) =>
      UserDto(
        exportVersion: exportVersion,
        name: userName,
        weekSettings: WeekSettingDto.fromAppModel(weekSetting),
        eventSettings: eventSettings.map(EventSettingDto.fromAppModel).toList(),
        globalSettings: GlobalSettingsDto(
          settings: globalSettings,
        ),
        dayValues: dayValues.map(DayValueDto.fromAppModel).toList(),
        weekValues: weekValues.map(WeekValueDto.fromAppModel).toList(),
      );

  Map<String, dynamic> toJson() => {
        'exportVersion': exportVersion,
        'name': name,
        'weekSettings': weekSettings,
        'eventSettings': eventSettings,
        'globalSettings': globalSettings,
        'dayValues': dayValues,
        'weekValues': weekValues,
      };

  ({
    int exportVersion,
    String userName,
    WeekSetting weekSetting,
    List<EventSetting> eventSettings,
    SettingsMap globalSettings,
    List<DayValue> dayValues,
    List<WeekValue> weekValues,
  }) toAppModel() => (
        exportVersion: exportVersion,
        userName: name,
        weekSetting: weekSettings.toAppModel(),
        eventSettings: eventSettings.map((e) => e.toAppModel()).toList(),
        globalSettings: globalSettings.settings,
        dayValues: dayValues.map((e) => e.toAppModel()).toList(),
        weekValues: weekValues.map((e) => e.toAppModel()).toList(),
      );
}
