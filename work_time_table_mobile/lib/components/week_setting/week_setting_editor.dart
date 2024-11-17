import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/components/validation_result_display.dart';
import 'package:work_time_table_mobile/components/week_setting/global_week_day_setting_input.dart';
import 'package:work_time_table_mobile/components/week_setting/global_week_day_setting_input_header.dart';
import 'package:work_time_table_mobile/components/week_setting/week_day_setting_input.dart';
import 'package:work_time_table_mobile/components/week_setting/week_day_setting_input_header.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_day_setting.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/week_setting_service.dart';
import 'package:work_time_table_mobile/utils.dart';

class WeekSettingEditor extends StatefulWidget {
  const WeekSettingEditor({
    super.key,
    required this.initialValue,
    required this.onSubmit,
  });

  final WeekSetting initialValue;
  final void Function(WeekSetting value) onSubmit;

  @override
  State<WeekSettingEditor> createState() => _WeekSettingEditorState();
}

class _WeekSettingEditorState extends State<WeekSettingEditor> {
  void _loadInitialValues() => _updateValue(
        widget.initialValue,
        widget.initialValue.weekDaySettings.keys.toList(),
      );

  @override
  void initState() {
    _loadInitialValues();
    super.initState();
  }

  var _currentWeekSettingValue = WeekSetting(
    targetWorkTimePerWeek: 0,
    weekDaySettings: {},
  );
  var _currentActiveWorkDays = <DayOfWeek>[];

  var _currentValidationErrors = <AppError>[];

  WeekSetting _buildValidatableWeekSettingValue(
    WeekSetting weekSettingValue,
    List<DayOfWeek> activeWorkDays,
  ) =>
      WeekSetting(
        targetWorkTimePerWeek: weekSettingValue.targetWorkTimePerWeek,
        weekDaySettings: {
          for (var element in activeWorkDays)
            element: weekSettingValue.weekDaySettings[element] ??
                WeekDaySetting(
                  dayOfWeek: element,
                  timeEquivalent: 0,
                  mandatoryWorkTimeStart: 0,
                  mandatoryWorkTimeEnd: 0,
                  defaultWorkTimeStart: 0,
                  defaultWorkTimeEnd: 0,
                  defaultBreakDuration: 0,
                ),
        },
      );

  void _updateValue(
    WeekSetting weekSettingValue,
    List<DayOfWeek> activeWorkDays,
  ) {
    final validationResult = WeekSettingService.getWeekSettingsValidator(
      _buildValidatableWeekSettingValue(
        weekSettingValue,
        activeWorkDays,
      ),
    ).validateAll();
    setState(() {
      _currentWeekSettingValue = weekSettingValue;
      _currentActiveWorkDays = activeWorkDays;
      _currentValidationErrors = validationResult;
    });
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GlobalWeekDaySettingInputHeader(),
              GlobalWeekDaySettingInput(
                initialTargetWorkTimePerWeek:
                    _currentWeekSettingValue.targetWorkTimePerWeek,
                onChangeTargetWorkTimePerWeek: (value) => _updateValue(
                  WeekSetting(
                    targetWorkTimePerWeek: value,
                    weekDaySettings: _currentWeekSettingValue.weekDaySettings,
                  ),
                  _currentActiveWorkDays,
                ),
              ),
              const WeekDaySettingInputHeader(),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final day in DayOfWeek.values)
                    ExpansionTile(
                      title: Text(day.name.capitalized),
                      subtitle: Text(
                        _currentActiveWorkDays.contains(day)
                            ? 'Work day (${(_currentWeekSettingValue.weekDaySettings[day]?.timeEquivalent ?? 0).toTimeOfDay().format(context)} hours)'
                            : 'Non-work day',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      children: [
                        CheckboxListTile(
                          title: const Text('Mark as work day'),
                          value: _currentActiveWorkDays.contains(day),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            if (value ?? false) {
                              _updateValue(
                                _currentWeekSettingValue,
                                [..._currentActiveWorkDays, day],
                              );
                            } else {
                              _updateValue(
                                _currentWeekSettingValue,
                                _currentActiveWorkDays
                                    .where((element) => element != day)
                                    .toList(),
                              );
                            }
                          },
                        ),
                        WeekDaySettingInput(
                          initialValue:
                              _currentWeekSettingValue.weekDaySettings[day] ??
                                  WeekDaySetting(
                                    dayOfWeek: day,
                                    timeEquivalent: 0,
                                    mandatoryWorkTimeStart: 0,
                                    mandatoryWorkTimeEnd: 0,
                                    defaultWorkTimeStart: 0,
                                    defaultWorkTimeEnd: 0,
                                    defaultBreakDuration: 0,
                                  ),
                          onChange: (value) => _updateValue(
                            WeekSetting(
                              targetWorkTimePerWeek: _currentWeekSettingValue
                                  .targetWorkTimePerWeek,
                              weekDaySettings:
                                  _currentWeekSettingValue.weekDaySettings
                                    ..update(
                                      day,
                                      (oldValue) => value,
                                      ifAbsent: () => value,
                                    ),
                            ),
                            _currentActiveWorkDays,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          ValidationResultDisplay(
            handledErrors: const [
              AppError.service_weekSettings_invalidTargetWorktime,
            ],
            occurredErrors: _currentValidationErrors,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _loadInitialValues,
                child: const Text('Reset'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () =>
                    widget.onSubmit(_buildValidatableWeekSettingValue(
                  _currentWeekSettingValue,
                  _currentActiveWorkDays,
                )),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      );
}
