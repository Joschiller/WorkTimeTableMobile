import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/settings/global_setting/scroll_interval_setting_input.dart';
import 'package:work_time_table_mobile/models/global_setting_key.dart';
import 'package:work_time_table_mobile/models/settings_map.dart';

class GlobalSettingEditor extends StatelessWidget {
  const GlobalSettingEditor({
    super.key,
    required this.initialValue,
    required this.onChange,
  });

  final SettingsMap initialValue;
  final void Function(
    GlobalSettingKey key,
    String? value,
  ) onChange;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScrollIntervalSettingInput(
            initialValue: initialValue[GlobalSettingKey.scrollInterval],
            onChange: (value) =>
                onChange(GlobalSettingKey.scrollInterval, value),
            onReset: () => onChange(GlobalSettingKey.scrollInterval, null),
          ),
        ],
      );
}
