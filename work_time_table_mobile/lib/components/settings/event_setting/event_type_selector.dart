import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/models/event_setting/event_type.dart';

class EventTypeSelector extends StatelessWidget {
  const EventTypeSelector({
    super.key,
    required this.eventType,
    required this.onChange,
  });

  final EventType eventType;

  final void Function(EventType eventType) onChange;

  @override
  Widget build(BuildContext context) => DropdownButton<String>(
        value: eventType.name,
        onChanged: (String? value) => onChange(
            EventType.values.firstWhere((element) => element.name == value)),
        items: EventType.values
            .map<DropdownMenuItem<String>>((value) => DropdownMenuItem<String>(
                  value: value.name,
                  child: Text(value.displayValue),
                ))
            .toList(),
      );
}
