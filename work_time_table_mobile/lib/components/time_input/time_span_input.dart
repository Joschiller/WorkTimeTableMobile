import 'dart:math';

import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/time_input/time_input_button.dart';
import 'package:work_time_table_mobile/utils.dart';

class TimeSpanInput extends StatelessWidget {
  const TimeSpanInput({
    super.key,
    required this.value,
    TimeOfDay? startMin,
    TimeOfDay? startMax,
    TimeOfDay? endMin,
    TimeOfDay? endMax,
    required this.onChange,
  })  : startMin = startMin ?? const TimeOfDay(hour: 0, minute: 0),
        startMax = startMax ?? const TimeOfDay(hour: 23, minute: 59),
        endMin = endMin ?? const TimeOfDay(hour: 0, minute: 0),
        endMax = endMax ?? const TimeOfDay(hour: 23, minute: 59);

  final ({TimeOfDay? start, TimeOfDay? end}) value;
  final TimeOfDay startMin;
  final TimeOfDay startMax;
  final TimeOfDay endMin;
  final TimeOfDay endMax;
  final void Function(TimeOfDay start, TimeOfDay end) onChange;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 50,
                child: Text(
                  'Start:',
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              TimeInputButton(
                value: value.start,
                min: startMin,
                max: value.end != null
                    ? min(startMax.toInt(), value.end!.toInt()).toTimeOfDay()
                    : startMax,
                onChange: (newValue) =>
                    onChange(newValue, value.end ?? newValue),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 50,
                child: Text(
                  'End:',
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              TimeInputButton(
                value: value.end,
                min: value.start != null
                    ? max(endMin.toInt(), value.start!.toInt()).toTimeOfDay()
                    : endMin,
                max: endMax,
                onChange: (newValue) =>
                    onChange(value.start ?? newValue, newValue),
              ),
            ],
          ),
        ],
      );
}
