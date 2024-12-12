import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/event_setting/event_display.dart';
import 'package:work_time_table_mobile/models/event_setting/evaluated_event_setting.dart';

class EventList extends StatelessWidget {
  const EventList({
    super.key,
    required this.events,
  });

  final List<EvaluatedEventSetting> events;

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          child: EventDisplay(event: events[index]),
        ),
      );
}
