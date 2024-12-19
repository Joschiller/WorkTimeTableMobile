import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/time_input/day_mode_selector.dart';
import 'package:work_time_table_mobile/components/time_input/time_input_button.dart';
import 'package:work_time_table_mobile/components/time_input/time_span_input.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_day_setting.dart';
import 'package:work_time_table_mobile/utils.dart';

class DayInputCard extends StatelessWidget {
  const DayInputCard({
    super.key,
    required this.settings,
    required this.dayValue,
    required this.onChange,
  });

  final WeekDaySetting settings;
  final DayValue dayValue;

  final void Function(DayValue dayValue) onChange;

  @override
  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: Colors.grey.shade400),
        ),
        color: Colors.grey.shade300,
        elevation: 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayDateFormat.format(dayValue.date),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              DayOfWeek.fromDateTime(dayValue.date).name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          'Work time',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TimeSpanInput(
                        value: (
                          start: dayValue.workTimeStart.toTimeOfDay(),
                          end: dayValue.workTimeEnd.toTimeOfDay()
                        ),
                        startMax: settings.mandatoryWorkTimeStart.toTimeOfDay(),
                        endMin: settings.mandatoryWorkTimeEnd.toTimeOfDay(),
                        onChange: (start, end) => onChange(DayValue(
                          date: dayValue.date,
                          firstHalfMode: dayValue.firstHalfMode,
                          secondHalfMode: dayValue.secondHalfMode,
                          workTimeStart: start.toInt(),
                          workTimeEnd: end.toInt(),
                          breakDuration: dayValue.breakDuration,
                        )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Break Duration',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TimeInputButton(
                        value: dayValue.breakDuration.toTimeOfDay(),
                        onChange: (value) => onChange(DayValue(
                          date: dayValue.date,
                          firstHalfMode: dayValue.firstHalfMode,
                          secondHalfMode: dayValue.secondHalfMode,
                          workTimeStart: dayValue.workTimeStart,
                          workTimeEnd: dayValue.workTimeEnd,
                          breakDuration: value.toInt(),
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Forenoon',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      DayModeSelector(
                        dayMode: dayValue.firstHalfMode,
                        onChange: (dayMode) => onChange(DayValue(
                          date: dayValue.date,
                          firstHalfMode: dayMode,
                          secondHalfMode: dayValue.secondHalfMode,
                          workTimeStart: dayValue.workTimeStart,
                          workTimeEnd: dayValue.workTimeEnd,
                          breakDuration: dayValue.breakDuration,
                        )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Afternoon',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      DayModeSelector(
                        dayMode: dayValue.secondHalfMode,
                        onChange: (dayMode) => onChange(DayValue(
                          date: dayValue.date,
                          firstHalfMode: dayValue.firstHalfMode,
                          secondHalfMode: dayMode,
                          workTimeStart: dayValue.workTimeStart,
                          workTimeEnd: dayValue.workTimeEnd,
                          breakDuration: dayValue.breakDuration,
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
