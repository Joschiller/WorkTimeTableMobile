import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/blocs/week_setting_cubit.dart';
import 'package:work_time_table_mobile/components/page_template.dart';
import 'package:work_time_table_mobile/components/week_setting/week_setting_editor.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/services/week_setting_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

class WeekSettingScreen extends StatelessWidget {
  const WeekSettingScreen({super.key});

  @override
  Widget build(BuildContext context) => PageTemplate(
        title: 'Week Settings',
        content: BlocProvider(
          create: (context) => WeekSettingCubit(WeekSettingService(
            UserService(
              context.read<UserDao>(),
              context.read<CurrentUserDao>(),
            ),
            context.read<WeekSettingDao>(),
          )),
          child:
              BlocBuilder<WeekSettingCubit, ContextDependentValue<WeekSetting>>(
            builder: (context, state) => switch (state) {
              NoContextValue() => const Center(
                  child: Text('No user selected'),
                ),
              ContextValue(value: var value) => WeekSettingEditor(
                  initialValue: value,
                  onSubmit: context.read<WeekSettingCubit>().updateWeekSettings,
                ),
            },
          ),
        ),
      );
}
