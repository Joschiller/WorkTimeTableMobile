import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/time_input/duration_input.dart';

class GlobalWeekDaySettingInput extends StatelessWidget {
  const GlobalWeekDaySettingInput({
    super.key,
    required this.initialTargetWorkTimePerWeek,
    required this.onChangeTargetWorkTimePerWeek,
  });

  final int initialTargetWorkTimePerWeek;
  final void Function(int value) onChangeTargetWorkTimePerWeek;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DurationInput(
                initialValue: initialTargetWorkTimePerWeek,
                onChange: onChangeTargetWorkTimePerWeek,
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      );
}
