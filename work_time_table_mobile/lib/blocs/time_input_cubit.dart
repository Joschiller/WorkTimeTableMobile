import 'dart:async';

import 'package:work_time_table_mobile/models/value/day_mode.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/services/time_input_service.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/services/week_setting_service.dart';
import 'package:work_time_table_mobile/services/week_value_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_cubit.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/multi_stream_listener.dart';
import 'package:work_time_table_mobile/utils.dart';

class TimeInputCubit extends ContextDependentCubit<WeekInformation> {
  final _subscriptions = <StreamSubscription>[];

  TimeInputCubit(
    this._userService,
    this._weekSettingService,
    this._eventSettingService,
    this._timeInputService,
  ) : super(NoContextValue()) {
    _subscriptions.add(_userService.currentUserStream.stream
        .listen((user) => runContextDependentAction(
              user,
              () => emit(NoContextValue()),
              (user) => _intializeValues(),
            )));
    _subscriptions.addAll(listenForStreams(
      [
        _weekSettingService.weekSettingStream.stream,
        _eventSettingService.eventSettingStream.stream,
        _timeInputService.dayValueStream.stream,
        _timeInputService.weekValueStream.stream,
      ],
      () => _loadValueForWeek(0),
    ));
    runContextDependentAction(
      _userService.currentUserStream.state,
      () => emit(NoContextValue()),
      (user) => _intializeValues(),
    );
  }

  final UserService _userService;
  final WeekSettingService _weekSettingService;
  final EventSettingService _eventSettingService;
  final TimeInputService _timeInputService;

  Future<void> onReset(DayValue oldDayValue) =>
      _timeInputService.onReset(oldDayValue);

  Future<void> updateWorkTime(
    DayValue oldDayValue,
    ({
      int workTimeStart,
      int workTimeEnd,
    }) workTime,
  ) =>
      _timeInputService.updateWorkTime(oldDayValue, workTime);

  Future<void> updateBreakDuration(
    DayValue oldDayValue,
    int breakDuration,
  ) =>
      _timeInputService.updateBreakDuration(oldDayValue, breakDuration);

  Future<void> updateFirstHalfMode(
    DayValue oldDayValue,
    DayMode firstHalfMode,
  ) =>
      _timeInputService.updateFirstHalfMode(oldDayValue, firstHalfMode);

  Future<void> updateSecondHalfMode(
    DayValue oldDayValue,
    DayMode secondHalfMode,
  ) =>
      _timeInputService.updateSecondHalfMode(oldDayValue, secondHalfMode);

  Future<void> resetDaysOfWeek(DateTime weekStartDate, bool isConfirmed) =>
      _timeInputService.resetDaysOfWeek(weekStartDate, isConfirmed);

  Future<void> closeWeek(
    DateTime weekStartDate,
    List<DayValue> dayValues,
    bool isConfirmed,
  ) =>
      _timeInputService.closeWeek(weekStartDate, dayValues, isConfirmed);

  void _intializeValues() => _timeInputService
      .loadData(switch (_userService.currentUserStream.state) {
        NoContextValue() => null,
        ContextValue(value: final user) => user.id,
      })
      .then(
        (value) => emit(_timeInputService.getValuesForWeek(
          TimeInputService.getStartDateOfWeek(DateTime.now().toDay()),
        )),
      );

  void _loadValueForWeek(int relativeWeeks) => emit(switch (state) {
        NoContextValue() => NoContextValue(),
        ContextValue(value: var weekInformation) =>
          _timeInputService.getValuesForWeek(
            weekInformation.weekStartDate
                .add(Duration(days: 7 * relativeWeeks))
                .toDay(),
          ),
      });

  void loadWeekContainingDay(DateTime day) => emit(switch (state) {
        NoContextValue() => NoContextValue(),
        ContextValue() =>
          _timeInputService.getValuesForWeek(day.firstDayOfWeek),
      });

  void weekForwards() => _loadValueForWeek(1);

  void weekBackwards() => _loadValueForWeek(-1);

  @override
  Future<void> close() {
    for (var s in _subscriptions) {
      s.cancel();
    }
    _userService.close();
    _weekSettingService.close();
    _eventSettingService.close();
    _timeInputService.close();
    return super.close();
  }
}
