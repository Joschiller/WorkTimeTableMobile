import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/blocs/global_setting_cubit.dart';
import 'package:work_time_table_mobile/components/no_user_page.dart';
import 'package:work_time_table_mobile/components/page_template.dart';
import 'package:work_time_table_mobile/components/settings/global_setting/global_setting_editor.dart';
import 'package:work_time_table_mobile/models/settings_map.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

class GlobalSettingScreen extends StatelessWidget {
  const GlobalSettingScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<GlobalSettingCubit, ContextDependentValue<SettingsMap>>(
        builder: (context, state) => switch (state) {
          NoContextValue() => const NoUserPage(
              title: 'Global Settings',
            ),
          ContextValue(value: var value) => PageTemplate(
              title: 'Global Settings',
              content: GlobalSettingEditor(
                initialValue: value,
                onChange: context.read<GlobalSettingCubit>().updateSetting,
              ),
            ),
        },
      );
}
