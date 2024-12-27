import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/components/event_setting/event_repetition_input.dart';
import 'package:work_time_table_mobile/components/event_setting/event_time_span_input.dart';
import 'package:work_time_table_mobile/components/event_setting/event_type_selector.dart';
import 'package:work_time_table_mobile/components/validation_result_display.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/event_type.dart';
import 'package:work_time_table_mobile/models/event_setting/month_based_repetition_rule.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/utils.dart';

class EventSettingEditor extends StatefulWidget {
  const EventSettingEditor({
    super.key,
    this.initialValue,
    required this.onCancel,
    required this.onSubmit,
  });

  final EventSetting? initialValue;
  final void Function() onCancel;
  final Future<void> Function(EventSetting value) onSubmit;

  @override
  State<EventSettingEditor> createState() => _EventSettingEditorState();
}

class _EventSettingEditorState extends State<EventSettingEditor> {
  final TextEditingController textEditingController = TextEditingController();

  void _loadInitialValues() {
    if (widget.initialValue != null) {
      textEditingController.text = widget.initialValue!.title ?? '';
      _updateValue(widget.initialValue!);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialValues();
  }

  @override
  void didUpdateWidget(covariant EventSettingEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadInitialValues();
  }

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

  var _currentValidationErrors = <AppError>[];

  void _updateValue(EventSetting eventSetting) {
    final validationResult =
        EventSettingService.getEventValidator(eventSetting).validateAll();
    setState(() {
      _value = eventSetting;
      _currentValidationErrors = validationResult;
    });
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Event Type:',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(width: 16),
                                EventTypeSelector(
                                  eventType: _value.eventType,
                                  onChange: (eventType) =>
                                      _updateValue(EventSetting(
                                    id: _value.id,
                                    eventType: eventType,
                                    title: _value.title,
                                    startDate: _value.startDate,
                                    endDate: _value.endDate,
                                    startIsHalfDay: _value.startIsHalfDay,
                                    endIsHalfDay: _value.endIsHalfDay,
                                    dayBasedRepetitionRules:
                                        _value.dayBasedRepetitionRules,
                                    monthBasedRepetitionRules:
                                        _value.monthBasedRepetitionRules,
                                  )),
                                ),
                              ],
                            ),
                            TextField(
                              decoration: const InputDecoration(
                                label: Text('Title (optional)'),
                              ),
                              keyboardType: TextInputType.text,
                              maxLines: 1,
                              controller: textEditingController,
                              onChanged: (value) => _updateValue(EventSetting(
                                id: _value.id,
                                eventType: _value.eventType,
                                title: value,
                                startDate: _value.startDate,
                                endDate: _value.endDate,
                                startIsHalfDay: _value.startIsHalfDay,
                                endIsHalfDay: _value.endIsHalfDay,
                                dayBasedRepetitionRules:
                                    _value.dayBasedRepetitionRules,
                                monthBasedRepetitionRules:
                                    _value.monthBasedRepetitionRules,
                              )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: EventTimeSpanInput(
                          startDate: _value.startDate,
                          endDate: _value.endDate,
                          startIsHalfDay: _value.startIsHalfDay,
                          endIsHalfDay: _value.endIsHalfDay,
                          makeInternallyBounded: false,
                          onChange: (startDate, endDate, startIsHalfDay,
                                  endIsHalfDay) =>
                              _updateValue(EventSetting(
                            id: _value.id,
                            eventType: _value.eventType,
                            title: _value.title,
                            startDate: startDate,
                            endDate: endDate,
                            startIsHalfDay: startIsHalfDay,
                            endIsHalfDay: endIsHalfDay,
                            dayBasedRepetitionRules:
                                _value.dayBasedRepetitionRules,
                            monthBasedRepetitionRules:
                                _value.monthBasedRepetitionRules,
                          )),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Event Repetition:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  EventRepetitionInput(
                    initialDayBasedRepetitionRules:
                        _value.dayBasedRepetitionRules,
                    initialMonthBasedRepetitionRules:
                        _value.monthBasedRepetitionRules,
                    onChange:
                        (dayBasedRepetitionRules, monthBasedRepetitionRules) =>
                            _updateValue(EventSetting(
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
                      if (_value.startDate.countOfDayInMonth -
                              _value.startDate.day <
                          28)
                        MonthBasedRepetitionRuleBase(
                          // Xth to last day in month
                          dayIndex: _value.startDate.countOfDayInMonth -
                              _value.startDate.day,
                          weekIndex: null,
                          countFromEnd: true,
                        ),
                      if ((_value.startDate.day / 7).ceil() - 1 < 4)
                        MonthBasedRepetitionRuleBase(
                          // Xth day of week in month
                          dayIndex:
                              DayOfWeek.fromDateTime(_value.startDate).index,
                          weekIndex: (_value.startDate.day / 7).ceil() - 1,
                          countFromEnd: false,
                        ),
                      if (((_value.startDate.countOfDayInMonth -
                                      _value.startDate.day) /
                                  7)
                              .floor() <
                          4)
                        MonthBasedRepetitionRuleBase(
                          // Xth to last day of week in month
                          dayIndex:
                              DayOfWeek.fromDateTime(_value.startDate).index,
                          weekIndex: ((_value.startDate.countOfDayInMonth -
                                      _value.startDate.day) /
                                  7)
                              .floor(),
                          countFromEnd: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ValidationResultDisplay(
            handledErrors: const [
              AppError.service_eventSettings_invalid,
            ],
            occurredErrors: _currentValidationErrors,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => widget.onSubmit(_value).then(
                  (value) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('The settings were saved successfully.'),
                    ));
                  },
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      );
}
