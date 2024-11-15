import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/time_input/duration_input.dart';
import 'package:work_time_table_mobile/components/time_input/time_span_input.dart';
import 'package:work_time_table_mobile/models/week_setting/global_week_day_setting.dart';
import 'package:work_time_table_mobile/utils.dart';

class GlobalWeekDaySettingInput extends StatelessWidget {
  const GlobalWeekDaySettingInput({
    super.key,
    required this.initialGlobalWeekDaySeting,
    required this.initialTargetWorkTimePerWeek,
    required this.onChangeGlobalWeekDaySeting,
    required this.onChangeTargetWorkTimePerWeek,
  });

  final GlobalWeekDaySetting initialGlobalWeekDaySeting;
  final int initialTargetWorkTimePerWeek;
  final void Function(GlobalWeekDaySetting value) onChangeGlobalWeekDaySeting;
  final void Function(int value) onChangeTargetWorkTimePerWeek;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: TimeSpanInput(
              initialValue: (
                start: initialGlobalWeekDaySeting.defaultWorkTimeStart
                    .toTimeOfDay(),
                end:
                    initialGlobalWeekDaySeting.defaultWorkTimeEnd.toTimeOfDay(),
              ),
              onChange: (start, end) =>
                  onChangeGlobalWeekDaySeting(GlobalWeekDaySetting(
                defaultWorkTimeStart: start.toInt(),
                defaultWorkTimeEnd: end.toInt(),
                defaultMandatoryWorkTimeStart:
                    initialGlobalWeekDaySeting.defaultMandatoryWorkTimeStart,
                defaultMandatoryWorkTimeEnd:
                    initialGlobalWeekDaySeting.defaultMandatoryWorkTimeEnd,
                defaultBreakDuration:
                    initialGlobalWeekDaySeting.defaultBreakDuration,
              )),
            ),
          ),
          Expanded(
            child: TimeSpanInput(
              initialValue: (
                start: initialGlobalWeekDaySeting.defaultMandatoryWorkTimeStart
                    .toTimeOfDay(),
                end: initialGlobalWeekDaySeting.defaultMandatoryWorkTimeEnd
                    .toTimeOfDay(),
              ),
              onChange: (start, end) =>
                  onChangeGlobalWeekDaySeting(GlobalWeekDaySetting(
                defaultWorkTimeStart:
                    initialGlobalWeekDaySeting.defaultWorkTimeStart,
                defaultWorkTimeEnd:
                    initialGlobalWeekDaySeting.defaultWorkTimeEnd,
                defaultMandatoryWorkTimeStart: start.toInt(),
                defaultMandatoryWorkTimeEnd: end.toInt(),
                defaultBreakDuration:
                    initialGlobalWeekDaySeting.defaultBreakDuration,
              )),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DurationInput(
                initialValue: initialGlobalWeekDaySeting.defaultBreakDuration,
                max: 60 * 24,
                onChange: (value) =>
                    onChangeGlobalWeekDaySeting(GlobalWeekDaySetting(
                  defaultWorkTimeStart:
                      initialGlobalWeekDaySeting.defaultWorkTimeStart,
                  defaultWorkTimeEnd:
                      initialGlobalWeekDaySeting.defaultWorkTimeEnd,
                  defaultMandatoryWorkTimeStart:
                      initialGlobalWeekDaySeting.defaultMandatoryWorkTimeStart,
                  defaultMandatoryWorkTimeEnd:
                      initialGlobalWeekDaySeting.defaultMandatoryWorkTimeEnd,
                  defaultBreakDuration: value,
                )),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DurationInput(
                initialValue: initialTargetWorkTimePerWeek,
                onChange: onChangeTargetWorkTimePerWeek,
              ),
            ),
          ),
        ],
      );
}
