import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:work_time_table_mobile/blocs/time_input_cubit.dart';
import 'package:work_time_table_mobile/components/page_template.dart';
import 'package:work_time_table_mobile/components/time_input/day_input_card.dart';
import 'package:work_time_table_mobile/constants/routes.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/day_value_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/daos/week_value_dao.dart';
import 'package:work_time_table_mobile/models/value/day_mode.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_day_setting.dart';
import 'package:work_time_table_mobile/services/day_value_service.dart';
import 'package:work_time_table_mobile/services/event_service.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/services/time_input_service.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/services/week_setting_service.dart';
import 'package:work_time_table_mobile/services/week_value_service.dart';
import 'package:work_time_table_mobile/utils.dart';

class TimeInputScreen extends StatefulWidget {
  TimeInputScreen({super.key});

  final todayKey = GlobalKey();

  @override
  State<TimeInputScreen> createState() => _TimeInputScreenState();
}

class _TimeInputScreenState extends State<TimeInputScreen> {
  late DateTime selectedDay;

  DateTime get _weekOfToday => DateTime.now().toDay().firstDayOfWeek;

  @override
  void initState() {
    super.initState();
    _scrollToToday();
  }

  void _scrollToToday() {
    setState(() {
      selectedDay = _weekOfToday;
    });
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
            BlocProvider<TimeInputCubit>(
              create: (context) => TimeInputCubit(
                context.read<UserService>(),
                context.read<WeekSettingService>(),
                context.read<EventSettingService>(),
                context.read<TimeInputService>(),
              ),
            ),
          ],
          child: PageTemplate(
            title:
                '${displayDateFormat.format(selectedDay)} - ${displayDateFormat.format(
              selectedDay.add(const Duration(days: 6)),
            )}',
            menuButtons: [
              (
                onPressed: () => showDatePicker(
                      context: context,
                      initialDate: selectedDay,
                      firstDate: DateTime.utc(2020, 1, 1),
                      lastDate: DateTime.utc(DateTime.now().year + 5, 12, 31),
                    ).then(
                      (value) {
                        if (value != null) {
                          setState(() => selectedDay = value.firstDayOfWeek);
                        }
                      },
                    ),
                icon: const Icon(Icons.calendar_month),
              ),
              (
                onPressed: () => SettingsScreenRoute().push(context),
                icon: const Icon(Icons.settings),
              ),
            ],
            content: Column(
              children: [
                // TODO: show result of predecessor week
                Expanded(
                  child: Container(
                    color: Colors.grey.shade600,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // TODO: disable inputs, if the week cannot be edited anymore
                          ...DayOfWeek.values.map((dayOfWeek) => DayInputCard(
                                key: isSameDay(
                                        selectedDay.add(
                                            Duration(days: dayOfWeek.index)),
                                        DateTime.now())
                                    ? widget.todayKey
                                    : null,
                                // TODO: load settings
                                settings: WeekDaySetting(
                                  dayOfWeek: dayOfWeek,
                                  timeEquivalent: 0,
                                  mandatoryWorkTimeStart: 0,
                                  mandatoryWorkTimeEnd: 0,
                                  defaultWorkTimeStart: 0,
                                  defaultWorkTimeEnd: 0,
                                  defaultBreakDuration: 0,
                                ),
                                // TODO: load values
                                dayValue: DayValue(
                                  date: selectedDay
                                      .add(Duration(days: dayOfWeek.index)),
                                  breakDuration: 0,
                                  firstHalfMode: DayMode.workDay,
                                  secondHalfMode: DayMode.workDay,
                                  workTimeEnd: 0,
                                  workTimeStart: 0,
                                ),
                                onChange: (dayValue) {
                                  // TODO: instantly persist changes whenever a value is altered
                                },
                              ))
                          // TODO: if the week can be closed, show an additional card at the end for closing the week
                        ],
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => setState(() => selectedDay =
                              selectedDay.subtract(const Duration(days: 7))),
                          child: const Row(
                            children: [
                              Icon(Icons.arrow_left),
                              Text('Previous Week'),
                              SizedBox(width: 16),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _scrollToToday,
                          child: const Text('Today'),
                        ),
                        ElevatedButton(
                          onPressed: () => setState(() => selectedDay =
                              selectedDay.add(const Duration(days: 7))),
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
        ),
      );
}
