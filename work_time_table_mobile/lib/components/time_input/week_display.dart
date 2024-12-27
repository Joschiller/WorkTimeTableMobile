import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:work_time_table_mobile/components/time_input/day_input_card.dart';
import 'package:work_time_table_mobile/models/value/day_mode.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_day_setting.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/time_input_service.dart';
import 'package:work_time_table_mobile/services/week_value_service.dart';

class WeekDisplayOnChangeDay {
  final void Function(DayValue oldDayValue) onReset;
  final void Function(
    DayValue oldDayValue,
    ({
      int workTimeStart,
      int workTimeEnd,
    }) workTime,
  ) onChangeWorkTime;
  final void Function(
    DayValue oldDayValue,
    int breakDuration,
  ) onChangeBreakDuration;
  final void Function(
    DayValue oldDayValue,
    DayMode firstHalfMode,
  ) onChangeFirstHalfMode;
  final void Function(
    DayValue oldDayValue,
    DayMode secondHalfMode,
  ) onChangeSecondHalfMode;

  WeekDisplayOnChangeDay({
    required this.onReset,
    required this.onChangeWorkTime,
    required this.onChangeBreakDuration,
    required this.onChangeFirstHalfMode,
    required this.onChangeSecondHalfMode,
  });

  DayInputCardOnChange toDayInputCardOnChange(DayValue oldDayValue) =>
      DayInputCardOnChange(
        onReset: () => onReset(oldDayValue),
        onChangeWorkTime: (workTime) => onChangeWorkTime(oldDayValue, workTime),
        onChangeBreakDuration: (breakDuration) =>
            onChangeBreakDuration(oldDayValue, breakDuration),
        onChangeFirstHalfMode: (firstHalfMode) =>
            onChangeFirstHalfMode(oldDayValue, firstHalfMode),
        onChangeSecondHalfMode: (secondHalfMode) =>
            onChangeSecondHalfMode(oldDayValue, secondHalfMode),
      );
}

class WeekDisplay extends StatefulWidget {
  WeekDisplay({
    super.key,
    required this.weekSetting,
    required this.weekInformation,
    required this.onChangeDay,
    required this.onClose,
  });

  final WeekSetting weekSetting;
  final WeekInformation weekInformation;
  final WeekDisplayOnChangeDay onChangeDay;
  final void Function() onClose;

  final todayKey = GlobalKey();

  @override
  State<WeekDisplay> createState() => _WeekDisplayState();
}

class _WeekDisplayState extends State<WeekDisplay> {
  @override
  void initState() {
    super.initState();
    _scrollToToday();
  }

  @override
  void didUpdateWidget(covariant WeekDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(
      oldWidget.weekInformation.weekStartDate,
      widget.weekInformation.weekStartDate,
    )) {
      _scrollToToday();
    }
  }

  void _scrollToToday() {
    // small delay, to ensure, that the target date has been drawn
    Future.delayed(const Duration(milliseconds: 100)).then(
      (value) {
        if (widget.todayKey.currentContext != null) {
          Scrollable.ensureVisible(
            widget.todayKey.currentContext!,
            duration: const Duration(seconds: 2),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...DayOfWeek.values.map((dayOfWeek) => DayInputCard(
                key: isSameDay(
                        widget.weekInformation.weekStartDate
                            .add(Duration(days: dayOfWeek.index)),
                        DateTime.now())
                    ? widget.todayKey
                    : null,
                settings: widget.weekSetting.weekDaySettings[dayOfWeek] ??
                    WeekDaySetting.defaultValue(dayOfWeek),
                dayValue: widget.weekInformation.days[dayOfWeek]!,
                onChange: !widget.weekInformation.weekClosed &&
                        widget.weekInformation.days[dayOfWeek]?.firstHalfMode !=
                            DayMode.nonWorkDay &&
                        widget.weekInformation.days[dayOfWeek]
                                ?.secondHalfMode !=
                            DayMode.nonWorkDay
                    ? widget.onChangeDay.toDayInputCardOnChange(
                        widget.weekInformation.days[dayOfWeek]!)
                    : null,
              )),
          if (context
              .read<TimeInputService>()
              .getIsWeekClosableValidator(widget.weekInformation.weekStartDate)
              .isValid)
            Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: widget.onClose,
                behavior: HitTestBehavior.opaque,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                    side: BorderSide(color: Colors.yellow.shade400),
                  ),
                  color: Colors.yellow.shade300,
                  elevation: 8,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      Icons.event_available,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
