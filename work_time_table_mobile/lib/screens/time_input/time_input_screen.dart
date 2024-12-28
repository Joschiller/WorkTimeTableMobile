import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/blocs/time_input_cubit.dart';
import 'package:work_time_table_mobile/blocs/week_setting_cubit.dart';
import 'package:work_time_table_mobile/components/confirmable_alert_dialog.dart';
import 'package:work_time_table_mobile/components/page_template.dart';
import 'package:work_time_table_mobile/components/time_input/time_input_summary.dart';
import 'package:work_time_table_mobile/components/time_input/week_display.dart';
import 'package:work_time_table_mobile/constants/routes.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/day_value_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/daos/week_value_dao.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/day_value_service.dart';
import 'package:work_time_table_mobile/services/event_service.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/services/time_input_service.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/services/week_setting_service.dart';
import 'package:work_time_table_mobile/services/week_value_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/utils.dart';

class TimeInputScreen extends StatelessWidget {
  const TimeInputScreen({super.key});

  Future<void> _showClosingConfirmation(
    BuildContext context,
    Future<void> Function() doClose,
  ) async =>
      await showDialog(
        context: context,
        builder: (context) => ConfirmableAlertDialog(
          title: 'Close Week',
          content: const Text(
              'Do you really want to close the selected week permanently? You won\'t be able to edit any values of this week anymore afterwards.'),
          actionText: 'Close week',
          onCancel: Navigator.of(context).pop,
          onConfirm: () async {
            await doClose();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
      );

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
            create: (context) => TimeInputService(
              context.read<UserService>(),
              context.read<WeekSettingService>(),
              context.read<EventSettingService>(),
              context.read<DayValueDao>(),
              context.read<WeekValueDao>(),
              const WeekValueService(DayValueService(EventService())),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<WeekSettingCubit>(
              create: (context) => WeekSettingCubit(
                context.read<WeekSettingService>(),
              ),
            ),
            BlocProvider<TimeInputCubit>(
              create: (context) => TimeInputCubit(
                context.read<UserService>(),
                context.read<WeekSettingService>(),
                context.read<EventSettingService>(),
                context.read<TimeInputService>(),
              ),
            ),
          ],
          child:
              BlocBuilder<WeekSettingCubit, ContextDependentValue<WeekSetting>>(
            builder: (context, weekSettingState) => BlocBuilder<TimeInputCubit,
                ContextDependentValue<WeekInformation>>(
              builder: (context, weekState) => switch (weekSettingState) {
                NoContextValue<WeekSetting>() => const NoUserPage(),
                ContextValue<WeekSetting>(value: final weekSetting) => switch (
                      weekState) {
                    NoContextValue<WeekInformation>() => const NoUserPage(),
                    ContextValue<WeekInformation>(
                      value: final weekInformation
                    ) =>
                      PageTemplate(
                        title:
                            '${displayDateFormat.format(weekInformation.weekStartDate)} - ${displayDateFormat.format(
                          weekInformation.weekStartDate
                              .add(const Duration(days: 6)),
                        )}',
                        menuButtons: [
                          (
                            onPressed: () => showDatePicker(
                                  context: context,
                                  initialDate: weekInformation.weekStartDate,
                                  firstDate: DateTime.utc(2020, 1, 1),
                                  lastDate: DateTime.utc(
                                      DateTime.now().year + 5, 12, 31),
                                ).then(
                                  (value) {
                                    if (value != null && context.mounted) {
                                      context
                                          .read<TimeInputCubit>()
                                          .loadWeekContainingDay(value);
                                    }
                                  },
                                ),
                            icon: const Icon(Icons.calendar_month),
                          ),
                          (
                            onPressed: () =>
                                SettingsScreenRoute().push(context),
                            icon: const Icon(Icons.settings),
                          ),
                        ],
                        content: Column(
                          children: [
                            TimeInputSummary(
                              label: 'Result of predecessor week',
                              duration: weekInformation.resultOfPredecessorWeek,
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.grey.shade600,
                                child: WeekDisplay(
                                  weekSetting: weekSetting,
                                  weekInformation: weekInformation,
                                  onChangeDay: WeekDisplayOnChangeDay(
                                    onReset:
                                        context.read<TimeInputCubit>().onReset,
                                    onChangeWorkTime: context
                                        .read<TimeInputCubit>()
                                        .updateWorkTime,
                                    onChangeBreakDuration: context
                                        .read<TimeInputCubit>()
                                        .updateBreakDuration,
                                    onChangeFirstHalfMode: context
                                        .read<TimeInputCubit>()
                                        .updateFirstHalfMode,
                                    onChangeSecondHalfMode: context
                                        .read<TimeInputCubit>()
                                        .updateSecondHalfMode,
                                  ),
                                  onClose: () => _showClosingConfirmation(
                                    context,
                                    () => context
                                        .read<TimeInputCubit>()
                                        .closeWeek(
                                          WeekValue(
                                            weekStartDate:
                                                weekInformation.weekStartDate,
                                            targetTime: weekSetting
                                                .targetWorkTimePerWeek,
                                          ),
                                          weekInformation.days.values.toList(),
                                          true,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            TimeInputSummary(
                              label: 'Result of week',
                              duration: weekInformation.weekResult,
                            ),
                            const Divider(
                              height: 2,
                              indent: 0,
                              color: Colors.black,
                            ),
                            Container(
                              color: Colors.grey.shade300,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: context
                                          .read<TimeInputCubit>()
                                          .weekBackwards,
                                      child: const Row(
                                        children: [
                                          Icon(Icons.arrow_left),
                                          Text('Previous Week'),
                                          SizedBox(width: 16),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => context
                                          .read<TimeInputCubit>()
                                          .loadWeekContainingDay(
                                              DateTime.now()),
                                      child: const Text('Today'),
                                    ),
                                    ElevatedButton(
                                      onPressed: context
                                          .read<TimeInputCubit>()
                                          .weekForwards,
                                      child: const Row(
                                        children: [
                                          SizedBox(width: 16),
                                          Text('Next Week'),
                                          Icon(Icons.arrow_right),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                  },
              },
            ),
          ),
        ),
      );
}

class NoUserPage extends StatelessWidget {
  const NoUserPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) => PageTemplate(
        title: 'No user selected',
        menuButtons: [
          (
            onPressed: () => SettingsScreenRoute().push(context),
            icon: const Icon(Icons.settings),
          ),
        ],
        content: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No user selected'),
              Text('Go to the settings to configure a user'),
            ],
          ),
        ),
      );
}
