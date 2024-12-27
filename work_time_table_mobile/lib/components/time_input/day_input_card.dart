import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:work_time_table_mobile/components/time_input/day_mode_selector.dart';
import 'package:work_time_table_mobile/components/time_input/time_input_button.dart';
import 'package:work_time_table_mobile/components/time_input/time_span_input.dart';
import 'package:work_time_table_mobile/models/value/day_mode.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_day_setting.dart';
import 'package:work_time_table_mobile/utils.dart';

class DayInputCardOnChange {
  final void Function() onReset;
  final void Function(
    ({
      int workTimeStart,
      int workTimeEnd,
    }) workTime,
  ) onChangeWorkTime;
  final void Function(int breakDuration) onChangeBreakDuration;
  final void Function(DayMode firstHalfMode) onChangeFirstHalfMode;
  final void Function(DayMode secondHalfMode) onChangeSecondHalfMode;

  DayInputCardOnChange({
    required this.onReset,
    required this.onChangeWorkTime,
    required this.onChangeBreakDuration,
    required this.onChangeFirstHalfMode,
    required this.onChangeSecondHalfMode,
  });
}

class DayInputCard extends StatelessWidget {
  const DayInputCard({
    super.key,
    required this.settings,
    required this.dayValue,
    required this.onChange,
  });

  final WeekDaySetting settings;
  final DayValue dayValue;

  bool get _isPartiallyWorkday =>
      dayValue.firstHalfMode == DayMode.workDay ||
      dayValue.secondHalfMode == DayMode.workDay;

  final DayInputCardOnChange? onChange;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: BorderSide(
                color: (isSameDay(dayValue.date, DateTime.now())
                    ? Colors.yellow.shade400
                    : Colors.grey.shade400)),
          ),
          color: isSameDay(dayValue.date, DateTime.now())
              ? Colors.yellow.shade300
              : Colors.grey.shade300,
          elevation: 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SizedBox(width: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      displayDateFormat.format(dayValue.date),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  GestureDetector(
                    onTap: onChange?.onReset,
                    child: Icon(
                      Icons.undo,
                      color: onChange != null ? Colors.black : Colors.black26,
                    ),
                  ),
                ],
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
                          startMax:
                              settings.mandatoryWorkTimeStart.toTimeOfDay(),
                          endMin: settings.mandatoryWorkTimeEnd.toTimeOfDay(),
                          onChange: onChange != null && _isPartiallyWorkday
                              ? (start, end) => onChange?.onChangeWorkTime((
                                    workTimeStart: start.toInt(),
                                    workTimeEnd: end.toInt(),
                                  ))
                              : null,
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
                          onChange: onChange != null && _isPartiallyWorkday
                              ? (value) =>
                                  onChange?.onChangeBreakDuration(value.toInt())
                              : null,
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
                          onChange: onChange != null
                              ? (dayMode) =>
                                  onChange?.onChangeFirstHalfMode(dayMode)
                              : null,
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
                          onChange: onChange != null
                              ? (dayMode) =>
                                  onChange?.onChangeSecondHalfMode(dayMode)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
