import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/time_input/date_input_button.dart';
import 'package:work_time_table_mobile/components/week_setting/header_row.dart';

class EventTimeSpanInput extends StatelessWidget {
  const EventTimeSpanInput({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.startIsHalfDay,
    required this.endIsHalfDay,
    required this.onChange,
  });

  final DateTime startDate;
  final DateTime endDate;
  final bool startIsHalfDay;
  final bool endIsHalfDay;

  final void Function(
    DateTime startDate,
    DateTime endDate,
    bool startIsHalfDay,
    bool endIsHalfDay,
  ) onChange;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HeaderRow(
            headers: {
              'Start Date':
                  'If the start date is marked as a "half day", only the second half of that day will be affected by the event.',
              'End Date':
                  'If the end date is marked as a "half day", only the first half of that day will be affected by the event.',
            },
          ),
          Row(
            children: [
              Expanded(
                child: DateInputButton(
                  value: startDate,
                  max: endDate,
                  onChange: (value) => onChange(
                    value,
                    endDate,
                    startIsHalfDay,
                    endIsHalfDay,
                  ),
                ),
              ),
              Expanded(
                child: DateInputButton(
                  value: endDate,
                  min: startDate,
                  onChange: (value) => onChange(
                    startDate,
                    value,
                    startIsHalfDay,
                    endIsHalfDay,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Start is half day'),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: startIsHalfDay,
                  onChanged: startDate == endDate && endIsHalfDay
                      // prevent 0-duration events
                      ? null
                      : (value) => onChange(
                            startDate,
                            endDate,
                            value ?? false,
                            endIsHalfDay,
                          ),
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('End is half day'),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: endIsHalfDay,
                  onChanged: startDate == endDate && startIsHalfDay
                      // prevent 0-duration events
                      ? null
                      : (value) => onChange(
                            startDate,
                            endDate,
                            startIsHalfDay,
                            value ?? false,
                          ),
                ),
              ),
            ],
          ),
        ],
      );
}
