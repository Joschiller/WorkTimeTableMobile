import 'dart:math';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:work_time_table_mobile/components/event_setting/circle_decoration.dart';
import 'package:work_time_table_mobile/components/event_setting/event_type_marker.dart';
import 'package:work_time_table_mobile/models/event_setting/evaluated_event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/services/event_service.dart';

class EventCalendar extends StatefulWidget {
  const EventCalendar({super.key, required this.events});

  final List<EventSetting> events;

  final eventService = const EventService();

  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  var _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<EvaluatedEventSetting>> _selectedEvents;

  final _eventCache = <DateTime, List<EvaluatedEventSetting>>{};

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EventCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _eventCache.clear();
  }

  List<EvaluatedEventSetting> _getEventsForDay(DateTime day) {
    if (!_eventCache.keys.contains(day)) {
      _eventCache[day] = widget.eventService
          .getEventsAffectingDate(day, widget.events)
        ..sort((a, b) =>
            a.eventSetting.eventType.priority -
            b.eventSetting.eventType.priority);
    }
    return _eventCache[day]!;
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(200, 1, 1),
            lastDay: DateTime.utc(DateTime.now().year + 5, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(selectedDay, _selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedEvents.value = _getEventsForDay(selectedDay);
                });
              }
            },
            onPageChanged: (focusedDay) =>
                setState(() => _focusedDay = focusedDay),
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            calendarFormat: CalendarFormat.month,
            rangeSelectionMode: RangeSelectionMode.disabled,
            startingDayOfWeek: StartingDayOfWeek.monday,
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              prioritizedBuilder: (context, day, focusedDay) {
                final events = _eventCache[day]!;
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
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Text(value[index].eventSetting.title ?? ''),
                      const SizedBox(width: 8),
                      if (!value[index].firstHalf)
                        const Text('(only afternoon)'),
                      if (!value[index].secondHalf)
                        const Text('(only forenoon)'),
                      const Spacer(),
                      EventTypeMarker(
                          eventType: value[index].eventSetting.eventType),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}
