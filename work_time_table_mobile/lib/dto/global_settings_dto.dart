import 'package:work_time_table_mobile/models/global_setting_key.dart';
import 'package:work_time_table_mobile/models/settings_map.dart';

class GlobalSettingsDto {
  final SettingsMap settings;

  GlobalSettingsDto({required this.settings});

  factory GlobalSettingsDto.fromJson(Map<String, dynamic> json) =>
      GlobalSettingsDto(
        settings: {
          for (final e in GlobalSettingKey.values) e: json[e.name],
        },
      );

  Map<String, dynamic> toJson() => {
        for (final e in settings.entries) e.key.name: e.value,
      };
}
