import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/event_setting/event_type_marker.dart';
import 'package:work_time_table_mobile/components/selectable_card.dart';
import 'package:work_time_table_mobile/models/event_setting/evaluated_event_setting.dart';
import 'package:work_time_table_mobile/services/event_service.dart';

class EventDisplay extends StatelessWidget {
  const EventDisplay({
    super.key,
    required this.selected,
    required this.event,
  });

  final EvaluatedEventSetting event;
  final bool selected;
  final eventService = const EventService();

  @override
  Widget build(BuildContext context) => SelectableCard(
        selected: selected,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        event.eventSetting.title ?? '',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (event.eventSetting.title != null &&
                          event.eventSetting.title!.isNotEmpty)
                        const SizedBox(width: 4),
                      if (!event.firstHalf) const Text('(only afternoon)'),
                      if (!event.secondHalf) const Text('(only forenoon)'),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          eventService
                              .eventDurationToDisplayString(event.eventSetting),
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
            if (event.eventSetting.dayBasedRepetitionRules.isNotEmpty ||
                event.eventSetting.monthBasedRepetitionRules.isNotEmpty)
              Tooltip(
                message: [
                  ...event.eventSetting.dayBasedRepetitionRules.map((r) =>
                      'every ${r.repeatAfterDays > 1 ? '${r.repeatAfterDays} days' : 'day'}'),
                  ...event.eventSetting.monthBasedRepetitionRules.map((r) =>
                      'every ${r.repeatAfterMonths > 1 ? '${r.repeatAfterMonths}. month on the ' : ''}${r.toDisplayString()}'),
                ].join('\n'),
                child: const Icon(Icons.event_repeat),
              ),
            EventTypeMarker(eventType: event.eventSetting.eventType),
          ],
        ),
      );
}
