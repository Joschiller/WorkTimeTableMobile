import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/models/event_setting/event_type.dart';

class EventTypeMarker extends StatelessWidget {
  const EventTypeMarker({super.key, required this.eventType});

  final EventType eventType;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        color: eventType.color,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          child: Text(
            eventType.displayValue,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
}
