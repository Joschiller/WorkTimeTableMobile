import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/blocs/current_user_cubit.dart';
import 'package:work_time_table_mobile/blocs/event_setting_cubit.dart';
import 'package:work_time_table_mobile/blocs/user_cubit.dart';
import 'package:work_time_table_mobile/blocs/week_setting_cubit.dart';
import 'package:work_time_table_mobile/components/metadata_field.dart';
import 'package:work_time_table_mobile/components/page_template.dart';
import 'package:work_time_table_mobile/constants/routes.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/event_service.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/services/week_setting_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => UserService(
              context.read<UserDao>(),
              context.read<CurrentUserDao>(),
            ),
          ),
          RepositoryProvider(
            create: (context) => WeekSettingService(
              context.read<UserService>(),
              context.read<WeekSettingDao>(),
            ),
          ),
          RepositoryProvider(
            create: (context) => EventSettingService(
              context.read<UserService>(),
              context.read<EventSettingDao>(),
              const EventService(),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => UserCubit(
                context.read<UserService>(),
              ),
            ),
            BlocProvider(
              create: (context) => WeekSettingCubit(
                context.read<WeekSettingService>(),
              ),
            ),
            BlocProvider(
              create: (context) => EventSettingCubit(
                context.read<EventSettingService>(),
              ),
            ),
          ],
          child: PageTemplate(
            title: 'Settings',
            content: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Configuration',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => UserScreenRoute().push(context),
                        child: const Text('Users'),
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => WeekSettingScreenRoute().push(context),
                        child: const Text('Week Settings'),
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            EventSettingScreenRoute().push(context),
                        child: const Text('Event Settings'),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current user:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          BlocBuilder<CurrentUserCubit,
                              ContextDependentValue<User>>(
                            builder: (context, state) => Text(
                              switch (state) {
                                NoContextValue<User>() => '-',
                                ContextValue<User>(value: final user) =>
                                  user.name,
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: BlocBuilder<WeekSettingCubit,
                          ContextDependentValue<WeekSetting>>(
                        builder: (context, state) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MetadataField(
                              title: 'Target work time per week',
                              value: switch (state) {
                                NoContextValue<WeekSetting>() => 0.timeString,
                                ContextValue<WeekSetting>(
                                  value: final weekSetting
                                ) =>
                                  weekSetting.targetWorkTimePerWeek.timeString,
                              },
                              metadataTitleWeight: 4,
                              metadataValueWeight: 3,
                            ),
                            MetadataField(
                              title: 'Work days',
                              value: switch (state) {
                                NoContextValue<WeekSetting>() => '0',
                                ContextValue<WeekSetting>(
                                  value: final weekSetting
                                ) =>
                                  weekSetting.weekDaySettings.length.toString(),
                              },
                              metadataTitleWeight: 4,
                              metadataValueWeight: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: BlocBuilder<EventSettingCubit,
                          ContextDependentValue<List<EventSetting>>>(
                        builder: (context, state) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MetadataField(
                              title: 'Configured events',
                              value: switch (state) {
                                NoContextValue<List<EventSetting>>() => '0',
                                ContextValue<List<EventSetting>>(
                                  value: final events
                                ) =>
                                  events.length.toString(),
                              },
                              metadataTitleWeight: 4,
                              metadataValueWeight: 3,
                            ),
                            MetadataField(
                              title: 'Configured without repetition',
                              value: switch (state) {
                                NoContextValue<List<EventSetting>>() => '0',
                                ContextValue<List<EventSetting>>(
                                  value: final events
                                ) =>
                                  events
                                      .where((e) =>
                                          e.dayBasedRepetitionRules.isEmpty &&
                                          e.monthBasedRepetitionRules.isEmpty)
                                      .length
                                      .toString(),
                              },
                              metadataTitleWeight: 4,
                              metadataValueWeight: 3,
                            ),
                            MetadataField(
                              title: 'Configured with repetition',
                              value: switch (state) {
                                NoContextValue<List<EventSetting>>() => '0',
                                ContextValue<List<EventSetting>>(
                                  value: final events
                                ) =>
                                  events
                                      .where((e) =>
                                          e.dayBasedRepetitionRules
                                              .isNotEmpty ||
                                          e.monthBasedRepetitionRules
                                              .isNotEmpty)
                                      .length
                                      .toString(),
                              },
                              metadataTitleWeight: 4,
                              metadataValueWeight: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
