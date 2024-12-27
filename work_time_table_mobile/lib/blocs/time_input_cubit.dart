import 'dart:async';

import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
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
    // TODO: this NoContextValue may become a future source of errors when leaving and re-entering the time input screen -> probably must evaluate current state of _userService.currentUserStream.state to load the initial values (compare to other cubits for more details)
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

  Future<void> updateDayOfWeek(DayValue value) =>
      _timeInputService.updateDayOfWeek(value);

  Future<void> resetDaysOfWeek(DateTime weekStartDate, bool isConfirmed) =>
      _timeInputService.resetDaysOfWeek(weekStartDate, isConfirmed);

  Future<void> closeWeek(
    WeekValue value,
    List<DayValue> dayValues,
    bool isConfirmed,
  ) =>
      _timeInputService.closeWeek(value, dayValues, isConfirmed);

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
