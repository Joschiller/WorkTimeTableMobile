import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:work_time_table_mobile/blocs/time_input_cubit.dart';
import 'package:work_time_table_mobile/blocs/week_setting_cubit.dart';
import 'package:work_time_table_mobile/components/page_template.dart';
import 'package:work_time_table_mobile/components/time_input/day_input_card.dart';
import 'package:work_time_table_mobile/constants/routes.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/day_value_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/daos/week_value_dao.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_day_setting.dart';
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
                NoContextValue<WeekSetting>() => PageTemplate(
                    title: 'No user selected',
                    menuButtons: [
                      (
                        onPressed: () => SettingsScreenRoute().push(context),
                        icon: const Icon(Icons.settings),
                      ),
                    ],
                    content: const Center(
                      child: Text('No user selected'),
                    ),
                  ),
                ContextValue<WeekSetting>(value: final weekSetting) => switch (
                      weekState) {
                    NoContextValue<WeekInformation>() => PageTemplate(
                        title: 'No user selected',
                        menuButtons: [
                          (
                            onPressed: () =>
                                SettingsScreenRoute().push(context),
                            icon: const Icon(Icons.settings),
                          ),
                        ],
                        content: const Center(
                          child: Text('No user selected'),
                        ),
                      ),
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
                            // TODO: show result of predecessor week
                            Expanded(
                              child: Container(
                                color: Colors.grey.shade600,
                                child: WeekDisplay(
                                  weekSetting: weekSetting,
                                  weekInformation: weekInformation,
                                  onChange: context
                                      .read<TimeInputCubit>()
                                      .updateDayOfWeek,
                                  onClose: () =>
                                      context.read<TimeInputCubit>().closeWeek(
                                          WeekValue(
                                            weekStartDate:
                                                weekInformation.weekStartDate,
                                            targetTime: weekSetting
                                                .targetWorkTimePerWeek,
                                          ),
                                          weekInformation.days.values.toList(),
                                          false // TODO request confirmation
                                          ),
                                ),
                              ),
                            ),
                            // TODO: show result of this week
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

class WeekDisplay extends StatefulWidget {
  WeekDisplay({
    super.key,
    required this.weekSetting,
    required this.weekInformation,
    required this.onChange,
    required this.onClose,
  });

  final WeekSetting weekSetting;
  final WeekInformation weekInformation;
  final void Function(DayValue dayValue) onChange;
  final void Function() onClose;

  final todayKey = GlobalKey();

  @override
  State<WeekDisplay> createState() => _WeekDisplayState();
}

class _WeekDisplayState extends State<WeekDisplay> {
  @override
  void initState() {
    super.initState();
    _scrollToToday();
  }

  @override
  void didUpdateWidget(covariant WeekDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(
      oldWidget.weekInformation.weekStartDate,
      widget.weekInformation.weekStartDate,
    )) {
      _scrollToToday();
    }
  }

  void _scrollToToday() {
    // small delay, to ensure, that the target date has been drawn
    Future.delayed(const Duration(milliseconds: 100)).then(
      (value) {
        if (widget.todayKey.currentContext != null) {
          Scrollable.ensureVisible(
            widget.todayKey.currentContext!,
            duration: const Duration(seconds: 2),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // TODO: disable input for non-work-days
          // TODO: disable inptus if both halfs of day are not "work-day"
          ...DayOfWeek.values.map((dayOfWeek) => DayInputCard(
                key: isSameDay(
                        widget.weekInformation.weekStartDate
                            .add(Duration(days: dayOfWeek.index)),
                        DateTime.now())
                    ? widget.todayKey
                    : null,
                settings: widget.weekSetting.weekDaySettings[dayOfWeek] ??
                    WeekDaySetting.defaultValue(dayOfWeek),
                dayValue: widget.weekInformation.days[dayOfWeek]!,
                onChange:
                    !widget.weekInformation.weekClosed ? widget.onChange : null,
              ))
          // TODO: if the week can be closed, show an additional card at the end for closing the week
        ],
      ),
    );
  }
}
