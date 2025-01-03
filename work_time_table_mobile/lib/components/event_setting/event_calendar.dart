import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:work_time_table_mobile/blocs/evaluated_event_setting_cubit.dart';
import 'package:work_time_table_mobile/components/event_setting/circle_decoration.dart';
import 'package:work_time_table_mobile/components/event_setting/event_display.dart';
import 'package:work_time_table_mobile/models/event_setting/evaluated_event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/services/event_service.dart';
import 'package:work_time_table_mobile/utils.dart';

class EventCalendar extends StatefulWidget {
  const EventCalendar({super.key, required this.events});

  final List<EventSetting> events;

  final eventService = const EventService();

  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  var _focusedDay = DateTime.now().toDay();
  DateTime? _selectedDay;
  late final ValueNotifier<List<EvaluatedEventSetting>> _selectedEvents;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(context
        .read<EvaluatedEventSettingCubit>()
        .getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EventCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    context.read<EvaluatedEventSettingCubit>().resetCache();
    if (_selectedDay != null) {
      _selectDay(_selectedDay!);
    }
  }

  void _selectDay(DateTime day) => setState(() {
        _selectedDay = day;
        _focusedDay = day;
        _selectedEvents.value =
            context.read<EvaluatedEventSettingCubit>().getEventsForDay(day);
      });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(DateTime.now().year + 5, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(selectedDay, _selectedDay)) {
                _selectDay(selectedDay);
              }
            },
            onPageChanged: _selectDay,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            calendarFormat: CalendarFormat.month,
            rangeSelectionMode: RangeSelectionMode.disabled,
            startingDayOfWeek: StartingDayOfWeek.monday,
            eventLoader:
                context.read<EvaluatedEventSettingCubit>().getEventsForDay,
            calendarBuilders: CalendarBuilders(
              prioritizedBuilder: (context, day, focusedDay) {
                final events = context
                    .read<EvaluatedEventSettingCubit>()
                    .getEventsForDay(day);
                final firstHalfColor = widget.eventService
                    .getHighestPriorityEventFromList(events
                        .where((e) => e.firstHalf)
                        .map((e) => e.eventSetting)
                        .toList())
                    ?.eventType
                    .color;
                final secondHalfColor = widget.eventService
                    .getHighestPriorityEventFromList(events
                        .where((e) => e.secondHalf)
                        .map((e) => e.eventSetting)
                        .toList())
                    ?.eventType
                    .color;
                final backdropColor = isSameDay(day, focusedDay)
                    ? const Color(0xFF9A9A9A)
                    : isSameDay(day, DateTime.now())
                        ? const Color(0xFFCACACA)
                        : Colors.transparent;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.all(6.0),
                  padding: const EdgeInsets.all(0),
                  decoration: CircleDecoration(
                    colorLeft: firstHalfColor ?? backdropColor,
                    colorRight: secondHalfColor ?? backdropColor,
                    radius: 20,
                    rotation: 30 * pi / 180,
                    backdropColor:
                        firstHalfColor != null || secondHalfColor != null
                            ? backdropColor
                            : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      color: firstHalfColor != null || secondHalfColor != null
                          ? const Color(0xFFFAFAFA)
                          : Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _selectedEvents,
              builder: (context, value, child) => ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) => EventDisplay(
                  event: value[index],
                  selected: (value[index].firstHalf &&
                          value.indexed
                              .where((v) => v.$1 < index && v.$2.firstHalf)
                              .isEmpty) ||
                      (value[index].secondHalf &&
                          value.indexed
                              .where((v) => v.$1 < index && v.$2.secondHalf)
                              .isEmpty),
                ),
              ),
            ),
          ),
        ],
      );
}
