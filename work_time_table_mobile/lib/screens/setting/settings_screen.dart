import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/blocs/current_user_cubit.dart';
import 'package:work_time_table_mobile/blocs/event_setting_cubit.dart';
import 'package:work_time_table_mobile/blocs/export_cubit.dart';
import 'package:work_time_table_mobile/blocs/user_cubit.dart';
import 'package:work_time_table_mobile/blocs/week_setting_cubit.dart';
import 'package:work_time_table_mobile/components/page_template.dart';
import 'package:work_time_table_mobile/components/settings/settings_card.dart';
import 'package:work_time_table_mobile/constants/routes.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/day_value_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/daos/global_setting_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/daos/week_value_dao.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/event_service.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/services/export_service.dart';
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
          RepositoryProvider(
            create: (context) => ExportService(
              context.read<CurrentUserDao>(),
              context.read<WeekSettingDao>(),
              context.read<EventSettingDao>(),
              context.read<GlobalSettingDao>(),
              context.read<DayValueDao>(),
              context.read<WeekValueDao>(),
              context.read<UserService>(),
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
            BlocProvider(
              create: (context) => ExportCubit(
                context.read<ExportService>(),
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
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisSpacing: 32,
                    mainAxisSpacing: 32,
                    crossAxisCount: 3,
                    children: [
                      BlocBuilder<CurrentUserCubit,
                          ContextDependentValue<User>>(
                        builder: (context, state) => SettingsCard(
                          title: 'Users',
                          onTap: () => UserScreenRoute().push(context),
                          metadataTitleWeight: 1,
                          metadataValueWeight: 1,
                          metadata: {
                            'Current user': switch (state) {
                              NoContextValue<User>() => '-',
                              ContextValue<User>(value: final user) =>
                                user.name,
                            },
                          },
                          showMetadataVertical: true,
                          actions: [
                            (
                              text: 'Export Current User',
                              action:
                                  context.read<ExportCubit>().exportCurrentUser,
                            ),
                            (
                              text: 'Import User',
                              action: context.read<ExportCubit>().import,
                            ),
                          ],
                          iconMode: IconMode.edit,
                        ),
                      ),
                      BlocBuilder<WeekSettingCubit,
                          ContextDependentValue<WeekSetting>>(
                        builder: (context, state) => SettingsCard(
                          title: 'Week Settings',
                          onTap: () => WeekSettingScreenRoute().push(context),
                          metadataTitleWeight: 4,
                          metadataValueWeight: 3,
                          metadata: {
                            'Target work time per week': switch (state) {
                              NoContextValue<WeekSetting>() => 0.timeString,
                              ContextValue<WeekSetting>(
                                value: final weekSetting
                              ) =>
                                weekSetting.targetWorkTimePerWeek.timeString,
                            },
                            'Work days': switch (state) {
                              NoContextValue<WeekSetting>() => '0',
                              ContextValue<WeekSetting>(
                                value: final weekSetting
                              ) =>
                                weekSetting.weekDaySettings.length.toString(),
                            },
                          },
                          iconMode: IconMode.edit,
                        ),
                      ),
                      BlocBuilder<EventSettingCubit,
                          ContextDependentValue<List<EventSetting>>>(
                        builder: (context, state) => SettingsCard(
                          title: 'Event Settings',
                          onTap: () => EventSettingScreenRoute().push(context),
                          metadataTitleWeight: 4,
                          metadataValueWeight: 1,
                          metadata: {
                            'Configured events': switch (state) {
                              NoContextValue<List<EventSetting>>() => '0',
                              ContextValue<List<EventSetting>>(
                                value: final events
                              ) =>
                                events.length.toString(),
                            },
                            'Configured without repetition': switch (state) {
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
                            'Configured with repetition': switch (state) {
                              NoContextValue<List<EventSetting>>() => '0',
                              ContextValue<List<EventSetting>>(
                                value: final events
                              ) =>
                                events
                                    .where((e) =>
                                        e.dayBasedRepetitionRules.isNotEmpty ||
                                        e.monthBasedRepetitionRules.isNotEmpty)
                                    .length
                                    .toString(),
                            },
                          },
                          iconMode: IconMode.edit,
                        ),
                      ),
                      SettingsCard(
                        title: 'Global Settings',
                        onTap: () => GlobalSettingScreenRoute().push(context),
                        metadataTitleWeight: 1,
                        metadataValueWeight: 1,
                        iconMode: IconMode.edit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
