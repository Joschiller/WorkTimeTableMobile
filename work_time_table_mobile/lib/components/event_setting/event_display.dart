import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_time_table_mobile/components/event_setting/event_type_marker.dart';
import 'package:work_time_table_mobile/models/event_setting/evaluated_event_setting.dart';

final dateFormat = DateFormat('dd.MM.yyyy');

class EventDisplay extends StatelessWidget {
  const EventDisplay({
    super.key,
    required this.event,
  });

  final EvaluatedEventSetting event;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      event.eventSetting.title ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (!event.firstHalf) const Text('(only afternoon)'),
                    if (!event.secondHalf) const Text('(only forenoon)'),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${dateFormat.format(event.eventSetting.startDate)}${event.eventSetting.startIsHalfDay ? ' (afternoon)' : ''} - ${dateFormat.format(event.eventSetting.endDate)}${event.eventSetting.endIsHalfDay ? ' (forenoon)' : ''}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          EventTypeMarker(eventType: event.eventSetting.eventType),
        ],
      );
}
