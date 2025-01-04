import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/time_input/duration_input.dart';
import 'package:work_time_table_mobile/components/time_input/time_span_input.dart';
import 'package:work_time_table_mobile/models/week_setting/week_day_setting.dart';
import 'package:work_time_table_mobile/utils.dart';

class WeekDaySettingInput extends StatelessWidget {
  const WeekDaySettingInput({
    super.key,
    required this.value,
    required this.onChange,
  });

  final WeekDaySetting value;
  final void Function(WeekDaySetting value) onChange;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DurationInput(
                value: value.timeEquivalent,
                max: 60 * 24,
                onChange: (newValue) => onChange(WeekDaySetting(
                  dayOfWeek: value.dayOfWeek,
                  timeEquivalent: newValue,
                  mandatoryWorkTimeStart: value.mandatoryWorkTimeStart,
                  mandatoryWorkTimeEnd: value.mandatoryWorkTimeEnd,
                  defaultWorkTimeStart: value.defaultWorkTimeStart,
                  defaultWorkTimeEnd: value.defaultWorkTimeEnd,
                  defaultBreakDuration: value.defaultBreakDuration,
                )),
              ),
            ),
          ),
          Expanded(
            child: TimeSpanInput(
              value: (
                start: value.mandatoryWorkTimeStart.toTimeOfDay(),
                end: value.mandatoryWorkTimeEnd.toTimeOfDay(),
              ),
              onChange: (start, end) => onChange(WeekDaySetting(
                dayOfWeek: value.dayOfWeek,
                timeEquivalent: value.timeEquivalent,
                mandatoryWorkTimeStart: start.toInt(),
                mandatoryWorkTimeEnd: end.toInt(),
                defaultWorkTimeStart: value.defaultWorkTimeStart > start.toInt()
                    ? start.toInt()
                    : value.defaultWorkTimeStart,
                defaultWorkTimeEnd: value.defaultWorkTimeEnd < end.toInt()
                    ? end.toInt()
                    : value.defaultWorkTimeEnd,
                defaultBreakDuration: value.defaultBreakDuration,
              )),
            ),
          ),
          Expanded(
            child: TimeSpanInput(
              value: (
                start: value.defaultWorkTimeStart.toTimeOfDay(),
                end: value.defaultWorkTimeEnd.toTimeOfDay(),
              ),
              startMax: value.mandatoryWorkTimeStart.toTimeOfDay(),
              endMin: value.mandatoryWorkTimeEnd.toTimeOfDay(),
              onChange: (start, end) => onChange(WeekDaySetting(
                dayOfWeek: value.dayOfWeek,
                timeEquivalent: value.timeEquivalent,
                mandatoryWorkTimeStart: value.mandatoryWorkTimeStart,
                mandatoryWorkTimeEnd: value.mandatoryWorkTimeEnd,
                defaultWorkTimeStart: start.toInt(),
                defaultWorkTimeEnd: end.toInt(),
                defaultBreakDuration: value.defaultBreakDuration,
              )),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DurationInput(
                value: value.defaultBreakDuration,
                max: 60 * 24,
                onChange: (newValue) => onChange(WeekDaySetting(
                  dayOfWeek: value.dayOfWeek,
                  timeEquivalent: value.timeEquivalent,
                  mandatoryWorkTimeStart: value.mandatoryWorkTimeStart,
                  mandatoryWorkTimeEnd: value.mandatoryWorkTimeEnd,
                  defaultWorkTimeStart: value.defaultWorkTimeStart,
                  defaultWorkTimeEnd: value.defaultWorkTimeEnd,
                  defaultBreakDuration: newValue,
                )),
              ),
            ),
          ),
        ],
      );
}
