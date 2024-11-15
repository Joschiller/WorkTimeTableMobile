import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/time_input/duration_input.dart';
import 'package:work_time_table_mobile/components/time_input/time_span_input.dart';
import 'package:work_time_table_mobile/models/week_setting/week_day_setting.dart';
import 'package:work_time_table_mobile/utils.dart';

class WeekDaySettingInput extends StatelessWidget {
  const WeekDaySettingInput({
    super.key,
    required this.initialValue,
    required this.onChange,
  });

  final WeekDaySetting initialValue;
  final void Function(WeekDaySetting value) onChange;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: TimeSpanInput(
              initialValue: (
                start: initialValue.defaultWorkTimeStart?.toTimeOfDay(),
                end: initialValue.defaultWorkTimeEnd?.toTimeOfDay(),
              ),
              onChange: (start, end) => onChange(WeekDaySetting(
                dayOfWeek: initialValue.dayOfWeek,
                defaultWorkTimeStart: start.toInt(),
                defaultWorkTimeEnd: end.toInt(),
                mandatoryWorkTimeStart: initialValue.mandatoryWorkTimeStart,
                mandatoryWorkTimeEnd: initialValue.mandatoryWorkTimeEnd,
                defaultBreakDuration: initialValue.defaultBreakDuration,
                timeEquivalent: initialValue.timeEquivalent,
              )),
            ),
          ),
          Expanded(
            child: TimeSpanInput(
              initialValue: (
                start: initialValue.mandatoryWorkTimeStart?.toTimeOfDay(),
                end: initialValue.mandatoryWorkTimeEnd?.toTimeOfDay(),
              ),
              onChange: (start, end) => onChange(WeekDaySetting(
                dayOfWeek: initialValue.dayOfWeek,
                defaultWorkTimeStart: initialValue.defaultWorkTimeStart,
                defaultWorkTimeEnd: initialValue.defaultWorkTimeEnd,
                mandatoryWorkTimeStart: start.toInt(),
                mandatoryWorkTimeEnd: end.toInt(),
                defaultBreakDuration: initialValue.defaultBreakDuration,
                timeEquivalent: initialValue.timeEquivalent,
              )),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DurationInput(
                initialValue: initialValue.defaultBreakDuration,
                max: 60 * 24,
                onChange: (value) => onChange(WeekDaySetting(
                  dayOfWeek: initialValue.dayOfWeek,
                  defaultWorkTimeStart: initialValue.defaultWorkTimeStart,
                  defaultWorkTimeEnd: initialValue.defaultWorkTimeEnd,
                  mandatoryWorkTimeStart: initialValue.mandatoryWorkTimeStart,
                  mandatoryWorkTimeEnd: initialValue.mandatoryWorkTimeEnd,
                  defaultBreakDuration: value,
                  timeEquivalent: initialValue.timeEquivalent,
                )),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DurationInput(
                initialValue: initialValue.timeEquivalent,
                max: 60 * 24,
                onChange: (value) => onChange(WeekDaySetting(
                  dayOfWeek: initialValue.dayOfWeek,
                  defaultWorkTimeStart: initialValue.defaultWorkTimeStart,
                  defaultWorkTimeEnd: initialValue.defaultWorkTimeEnd,
                  mandatoryWorkTimeStart: initialValue.mandatoryWorkTimeStart,
                  mandatoryWorkTimeEnd: initialValue.mandatoryWorkTimeEnd,
                  defaultBreakDuration: initialValue.defaultBreakDuration,
                  timeEquivalent: value,
                )),
              ),
            ),
          ),
        ],
      );
}
