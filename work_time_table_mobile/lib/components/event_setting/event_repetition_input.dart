import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:work_time_table_mobile/models/event_setting/day_based_repetition_rule.dart';
import 'package:work_time_table_mobile/models/event_setting/month_based_repetition_rule.dart';

enum EventRepetitionInputGroup {
  none,
  day,
  month,
  ;
}

class EventRepetitionInput extends StatefulWidget {
  const EventRepetitionInput({
    super.key,
    required this.initialDayBasedRepetitionRules,
    required this.initialMonthBasedRepetitionRules,
    required this.availableMonthBasedRepetitionRules,
    required this.onChange,
  });

  final List<DayBasedRepetitionRule> initialDayBasedRepetitionRules;
  final List<MonthBasedRepetitionRule> initialMonthBasedRepetitionRules;
  final List<MonthBasedRepetitionRuleBase> availableMonthBasedRepetitionRules;
  final void Function(
    List<DayBasedRepetitionRule> dayBasedRepetitionRules,
    List<MonthBasedRepetitionRule> monthBasedRepetitionRules,
  ) onChange;

  @override
  State<EventRepetitionInput> createState() => _EventRepetitionInputState();
}

class _EventRepetitionInputState extends State<EventRepetitionInput> {
  final List<DayBasedRepetitionRule> dayBasedRepetitionRules = [];
  final List<MonthBasedRepetitionRule> monthBasedRepetitionRules = [];

  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dayBasedRepetitionRules.addAll(widget.initialDayBasedRepetitionRules);
    monthBasedRepetitionRules
        .addAll(widget.initialMonthBasedRepetitionRules.where((element) =>
            // ignore: collection_methods_unrelated_type
            widget.availableMonthBasedRepetitionRules.contains(element)));
    switch (_groupValue) {
      case EventRepetitionInputGroup.none:
        textEditingController.text = '1';
      case EventRepetitionInputGroup.day:
        textEditingController.text =
            dayBasedRepetitionRules.first.repeatAfterDays.toString();
      case EventRepetitionInputGroup.month:
        textEditingController.text =
            monthBasedRepetitionRules.first.repeatAfterMonths.toString();
    }
  }

  @override
  void didUpdateWidget(covariant EventRepetitionInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      monthBasedRepetitionRules.removeWhere((element) =>
          // ignore: collection_methods_unrelated_type
          !widget.availableMonthBasedRepetitionRules.contains(element));
    });
  }

  EventRepetitionInputGroup get _groupValue => dayBasedRepetitionRules.isEmpty
      ? monthBasedRepetitionRules.isEmpty
          ? EventRepetitionInputGroup.none
          : EventRepetitionInputGroup.month
      : EventRepetitionInputGroup.day;

  void onChange(
    List<DayBasedRepetitionRule> dayBasedRepetitionRules,
    List<MonthBasedRepetitionRule> monthBasedRepetitionRules,
  ) {
    setState(() {
      this.dayBasedRepetitionRules.clear();
      this.dayBasedRepetitionRules.addAll(dayBasedRepetitionRules);
      this.monthBasedRepetitionRules.clear();
      this.monthBasedRepetitionRules.addAll(monthBasedRepetitionRules);
      widget.onChange(dayBasedRepetitionRules, monthBasedRepetitionRules);
    });
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  title: const Text('No repetition'),
                  value: EventRepetitionInputGroup.none,
                  groupValue: _groupValue,
                  onChanged: (newValue) {
                    if (_groupValue != newValue) {
                      onChange([], []);
                    }
                  },
                ),
              ),
              Expanded(
                child: RadioListTile(
                  title: const Text('Repeat after ... days'),
                  value: EventRepetitionInputGroup.day,
                  groupValue: _groupValue,
                  onChanged: (newValue) {
                    if (_groupValue != newValue) {
                      onChange(
                        [DayBasedRepetitionRule(repeatAfterDays: 7)],
                        [],
                      );
                      textEditingController.text = '7';
                    }
                  },
                ),
              ),
              Expanded(
                child: RadioListTile(
                  title: const Text('Repeat after ... months'),
                  value: EventRepetitionInputGroup.month,
                  groupValue: _groupValue,
                  onChanged: (newValue) {
                    if (_groupValue != newValue) {
                      onChange(
                        [],
                        [
                          widget.availableMonthBasedRepetitionRules.first
                              .withRepeatAfterMonths(12)
                        ],
                      );
                      textEditingController.text = '12';
                    }
                  },
                ),
              ),
            ],
          ),
          IgnorePointer(
            ignoring: _groupValue == EventRepetitionInputGroup.none,
            child: Row(
              children: [
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      label: Text('Repetition'),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: textEditingController,
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed == null) return;
                      onChange(
                        dayBasedRepetitionRules
                            .map((e) => DayBasedRepetitionRule(
                                  repeatAfterDays: parsed,
                                ))
                            .toList(),
                        monthBasedRepetitionRules
                            .map((e) => MonthBasedRepetitionRule(
                                  repeatAfterMonths: parsed,
                                  monthBasedRepetitionRuleBase:
                                      e.monthBasedRepetitionRuleBase,
                                ))
                            .toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          IgnorePointer(
            ignoring: _groupValue != EventRepetitionInputGroup.month,
            child: Row(
              children: [
                const Spacer(flex: 2),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('on each ...'),
                      ...widget.availableMonthBasedRepetitionRules.map((e) =>
                          RadioListTile(
                            title: Text(e.toDisplayString()),
                            value: e,
                            groupValue: monthBasedRepetitionRules.firstOrNull,
                            onChanged: (newValue) {
                              if (monthBasedRepetitionRules.first != newValue) {
                                onChange([], [
                                  e.withRepeatAfterMonths(
                                      int.parse(textEditingController.text))
                                ]);
                              }
                            },
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
