import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/time_input/time_input_button.dart';

class TimeSpanInput extends StatelessWidget {
  const TimeSpanInput({
    super.key,
    required this.initialValue,
    required this.onChange,
  });

  final ({TimeOfDay? start, TimeOfDay? end}) initialValue;
  final void Function(TimeOfDay start, TimeOfDay end) onChange;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 100,
                child: Text(
                  'Start:',
                  textAlign: TextAlign.right,
                ),
              ),
              TimeInputButton(
                initialValue: initialValue.start,
                max: initialValue.end,
                onChange: (value) => onChange(value, initialValue.end ?? value),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 100,
                child: Text(
                  'End:',
                  textAlign: TextAlign.right,
                ),
              ),
              TimeInputButton(
                initialValue: initialValue.end,
                min: initialValue.start,
                onChange: (value) =>
                    onChange(initialValue.start ?? value, value),
              ),
            ],
          ),
        ],
      );
}
