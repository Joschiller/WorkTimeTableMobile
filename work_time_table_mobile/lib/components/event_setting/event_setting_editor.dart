import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/event_setting/event_repetition_input.dart';
import 'package:work_time_table_mobile/components/event_setting/event_time_span_input.dart';
import 'package:work_time_table_mobile/components/event_setting/event_type_selector.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/event_type.dart';
import 'package:work_time_table_mobile/models/event_setting/month_based_repetition_rule.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/utils.dart';

class EventSettingEditor extends StatefulWidget {
  const EventSettingEditor({
    super.key,
    this.initialValue,
    required this.onSubmit,
  });

  final EventSetting? initialValue;
  final Future<void> Function(EventSetting value) onSubmit;

  @override
  State<EventSettingEditor> createState() => _EventSettingEditorState();
}

class _EventSettingEditorState extends State<EventSettingEditor> {
  var _value = EventSetting(
    id: -1,
    eventType: EventType.vacation,
    title: null,
    startDate: DateTime.now().toDay(),
    endDate: DateTime.now().toDay(),
    startIsHalfDay: false,
    endIsHalfDay: false,
    dayBasedRepetitionRules: [],
    monthBasedRepetitionRules: [],
  );

  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      textEditingController.text = widget.initialValue!.title ?? '';
      _value = widget.initialValue!;
    }
  }

  int getCountOfDaysInStartMonth() => DateTimeRange(
        start: DateTime(_value.startDate.year, _value.startDate.month),
        end: DateTime(_value.startDate.year, _value.startDate.month + 1),
      ).duration.inDays;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              EventTypeSelector(
                eventType: _value.eventType,
                onChange: (eventType) => setState(() => _value = EventSetting(
                      id: _value.id,
                      eventType: eventType,
                      title: _value.title,
                      startDate: _value.startDate,
                      endDate: _value.endDate,
                      startIsHalfDay: _value.startIsHalfDay,
                      endIsHalfDay: _value.endIsHalfDay,
                      dayBasedRepetitionRules: _value.dayBasedRepetitionRules,
                      monthBasedRepetitionRules:
                          _value.monthBasedRepetitionRules,
                    )),
              ),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    label: Text('Title (optional)'),
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  controller: textEditingController,
                  onChanged: (value) => setState(() => _value = EventSetting(
                        id: _value.id,
                        eventType: _value.eventType,
                        title: value,
                        startDate: _value.startDate,
                        endDate: _value.endDate,
                        startIsHalfDay: _value.startIsHalfDay,
                        endIsHalfDay: _value.endIsHalfDay,
                        dayBasedRepetitionRules: _value.dayBasedRepetitionRules,
                        monthBasedRepetitionRules:
                            _value.monthBasedRepetitionRules,
                      )),
                ),
              )
            ],
          ),
          EventTimeSpanInput(
            startDate: _value.startDate,
            endDate: _value.endDate,
            startIsHalfDay: _value.startIsHalfDay,
            endIsHalfDay: _value.endIsHalfDay,
            onChange: (startDate, endDate, startIsHalfDay, endIsHalfDay) =>
                setState(() => _value = EventSetting(
                      id: _value.id,
                      eventType: _value.eventType,
                      title: _value.title,
                      startDate: startDate,
                      endDate: endDate,
                      startIsHalfDay: startIsHalfDay,
                      endIsHalfDay: endIsHalfDay,
                      dayBasedRepetitionRules: _value.dayBasedRepetitionRules,
                      monthBasedRepetitionRules:
                          _value.monthBasedRepetitionRules,
                    )),
          ),
          EventRepetitionInput(
            initialDayBasedRepetitionRules: _value.dayBasedRepetitionRules,
            initialMonthBasedRepetitionRules: _value.monthBasedRepetitionRules,
            onChange: (dayBasedRepetitionRules, monthBasedRepetitionRules) =>
                setState(() => _value = EventSetting(
                      id: _value.id,
                      eventType: _value.eventType,
                      title: _value.title,
                      startDate: _value.startDate,
                      endDate: _value.endDate,
                      startIsHalfDay: _value.startIsHalfDay,
                      endIsHalfDay: _value.endIsHalfDay,
                      dayBasedRepetitionRules: dayBasedRepetitionRules,
                      monthBasedRepetitionRules: monthBasedRepetitionRules,
                    )),
            availableMonthBasedRepetitionRules: [
              if (_value.startDate.day - 1 < 28)
                MonthBasedRepetitionRuleBase(
                  // Xth day of month
                  dayIndex: _value.startDate.day - 1,
                  weekIndex: null,
                  countFromEnd: false,
                ),
              if (getCountOfDaysInStartMonth() - _value.startDate.day < 28)
                MonthBasedRepetitionRuleBase(
                  // Xth to last day in month
                  dayIndex: getCountOfDaysInStartMonth() - _value.startDate.day,
                  weekIndex: null,
                  countFromEnd: true,
                ),
              if ((_value.startDate.day / 7).ceil() - 1 < 4)
                MonthBasedRepetitionRuleBase(
                  // Xth day of week in month
                  dayIndex: DayOfWeek.fromDateTime(_value.startDate).index,
                  weekIndex: (_value.startDate.day / 7).ceil() - 1,
                  countFromEnd: false,
                ),
              if (((getCountOfDaysInStartMonth() - _value.startDate.day) / 7)
                      .floor() <
                  4)
                MonthBasedRepetitionRuleBase(
                  // Xth to last day of week in month
                  dayIndex: DayOfWeek.fromDateTime(_value.startDate).index,
                  weekIndex:
                      ((getCountOfDaysInStartMonth() - _value.startDate.day) /
                              7)
                          .floor(),
                  countFromEnd: true,
                ),
            ],
          ),
        ],
      );
}
