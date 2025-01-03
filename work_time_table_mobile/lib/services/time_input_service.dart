import 'dart:math';

import 'package:table_calendar/table_calendar.dart';
import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/day_value_dao.dart';
import 'package:work_time_table_mobile/daos/week_value_dao.dart';
import 'package:work_time_table_mobile/models/value/day_mode.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/services/week_setting_service.dart';
import 'package:work_time_table_mobile/services/week_value_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/context/list/context_dependent_list_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/streamable_service.dart';
import 'package:work_time_table_mobile/utils.dart';
import 'package:work_time_table_mobile/validate_and_run.dart';
import 'package:work_time_table_mobile/validator.dart';

final _dayValueStream = ContextDependentListStream<DayValue>();
final _weekValueStream = ContextDependentListStream<WeekValue>();

class TimeInputService extends StreamableService {
  TimeInputService(
    this._userService,
    this._weekSettingService,
    this._eventSettingService,
    this._dayValueDao,
    this._weekValueDao,
    this._weekValueService,
  ) {
    registerSubscription(_userService.currentUserStream.stream
        .listen((selectedUser) => runContextDependentAction(
              selectedUser,
              () => loadData(null),
              (user) => loadData(user.id),
            )));
    prepareListen(_dayValueDao.stream, _dayValueStream);
    prepareListen(_weekValueDao.stream, _weekValueStream);
    runContextDependentAction(
      _userService.currentUserStream.state,
      () => loadData(null),
      (user) => loadData(user.id),
    );
  }

  final UserService _userService;
  final WeekSettingService _weekSettingService;
  final EventSettingService _eventSettingService;
  final DayValueDao _dayValueDao;
  final WeekValueDao _weekValueDao;
  final WeekValueService _weekValueService;

  ContextDependentListStream<DayValue> get dayValueStream => _dayValueStream;
  ContextDependentListStream<WeekValue> get weekValueStream => _weekValueStream;

  Validator _getDaysUpdateValidator(List<DayValue> values) => Validator([
        // 7 consecutive days, starting with monday
        () => values.length != 7 ? AppError.service_timeInput_invalid : null,
        () => values
                .asMap()
                .entries
                .any((element) => element.key + 1 != element.value.date.weekday)
            ? AppError.service_timeInput_invalid
            : null,
        // validate each day
        () => values
            .map(_getDayUpdateValidator)
            .map((v) => v.validate())
            .where((v) => v != null)
            .firstOrNull,
      ]);

  Validator _getDayUpdateValidator(DayValue day) => Validator([
        // week not already closed
        () => _getWeekNotAlreadyClosedValidator(day.date.firstDayOfWeek)
            .validate(),
        // empty values if completely not workDay
        () => day.firstHalfMode != DayMode.workDay &&
                day.secondHalfMode != DayMode.workDay &&
                (day.workTimeStart != 0 ||
                    day.workTimeEnd != 0 ||
                    day.breakDuration != 0)
            ? AppError.service_timeInput_invalid
            : null,
        // start <= end
        () => day.workTimeStart > day.workTimeEnd
            ? AppError.service_timeInput_invalid
            : null,
        // settings dependent validations
        () => runContextDependentAction(
              _weekSettingService.weekSettingStream.state,
              () => AppError.service_noUserLoaded,
              (weekSettings) =>
                  _getDayValueAgainstSettingsValidator(day, weekSettings)
                      .validate(),
            ),
      ]);

  Validator _getDayValueAgainstSettingsValidator(
    DayValue day,
    WeekSetting weekSettings,
  ) =>
      Validator([
        () {
          final settingForDay =
              weekSettings.weekDaySettings[DayOfWeek.fromDateTime(day.date)];
          if (settingForDay == null) {
            // configured nonWorkDays are stored as nonWorkDays
            return day.firstHalfMode != DayMode.nonWorkDay ||
                    day.secondHalfMode != DayMode.nonWorkDay
                ? AppError.service_timeInput_invalid
                : null;
          }

          final isFullWorkDay = day.firstHalfMode == DayMode.workDay &&
              day.secondHalfMode == DayMode.workDay;

          // work time respects manatory time start (in case it is a full work day)
          if (isFullWorkDay &&
              day.firstHalfMode == DayMode.workDay &&
              (day.workTimeStart > settingForDay.mandatoryWorkTimeStart)) {
            return AppError.service_timeInput_invalid;
          }
          // work time respects manatory time end (in case it is a full work day)
          if (isFullWorkDay &&
              day.secondHalfMode == DayMode.workDay &&
              (day.workTimeEnd < settingForDay.mandatoryWorkTimeEnd)) {
            return AppError.service_timeInput_invalid;
          }
          return null;
        },
      ]);

  Validator _getWeekStartIsMondayValidator(DateTime weekStartDate) =>
      Validator([
        () => DayOfWeek.fromDateTime(weekStartDate) != DayOfWeek.monday
            ? AppError.service_timeInput_invalid
            : null,
      ]);

  Validator _getWeekNotAlreadyClosedValidator(DateTime weekStartDate) =>
      Validator([
        () => runContextDependentAction(
              _weekValueDao.stream.state,
              () => null,
              (weekValues) => isWeekClosed(weekValues, weekStartDate)
                  ? AppError.service_timeInput_alreadyClosed
                  : null,
            ),
      ]);

  Validator _getHasOneDayOfWeekPassedValidator(DateTime weekStartDate) =>
      Validator([
        () => DateTime.now().toDay().isBefore(weekStartDate)
            ? AppError.service_timeInput_earlyClose
            : null,
      ]);

  Validator getIsWeekClosableValidator(DateTime weekStartDate) =>
      _getWeekStartIsMondayValidator(weekStartDate) +
      _getWeekNotAlreadyClosedValidator(weekStartDate) +
      _getHasOneDayOfWeekPassedValidator(weekStartDate) +
      // it must be the first week ever OR all prior weeks must be closed too
      Validator([
        () => switch (weekValueStream.state) {
              NoContextValue<List<WeekValue>>() =>
                AppError.service_noUserLoaded,
              ContextValue<List<WeekValue>>(value: final weekValues) =>
                weekValues.isNotEmpty &&
                        !weekValues.any((week) => isSameDay(week.weekStartDate,
                            weekStartDate.subtract(const Duration(days: 7))))
                    ? AppError.service_timeInput_missingPredecessorClose
                    : null,
            },
      ]);

  // NOTE: The initial values are not cached here as they will only be calculated, if the week has no stored values yet.
  // Re-calculating will only happen, if:
  // - a different week is selected which has no values yet OR the values of the current week are reset
  // or
  // - any settings changed WHILST a week with empty values is opened.
  // If just the values of the current week change, no evaluation of default values will be performed, thus not being ressource intensive.
  ContextDependentValue<WeekInformation> getValuesForWeek(
    DateTime weekStartDate,
  ) =>
      switch (_getValuesFromDaos()) {
        NoContextValue() => NoContextValue(),
        ContextValue(value: var values) =>
          ContextValue(_weekValueService.getValuesForWeek(
            weekStartDate,
            values,
          )),
      };

  ContextDependentValue<MergedDaoValues> _getValuesFromDaos() =>
      switch (_weekSettingService.weekSettingStream.state) {
        NoContextValue() => NoContextValue(),
        ContextValue(value: var weekSetting) => switch (
              _eventSettingService.eventSettingStream.state) {
            NoContextValue() => NoContextValue(),
            ContextValue(value: var eventSettings) => switch (
                  _dayValueDao.stream.state) {
                NoContextValue() => NoContextValue(),
                ContextValue(value: var dayValues) => switch (
                      _weekValueDao.stream.state) {
                    NoContextValue() => NoContextValue(),
                    ContextValue(value: var weekValues) => ContextValue((
                        weekSetting: weekSetting,
                        eventSettings: eventSettings,
                        dayValues: dayValues,
                        weekValues: weekValues,
                      )),
                  }
              }
          }
      };

  static DateTime getStartDateOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  Future<void> loadData(int? userId) async {
    await _dayValueDao.loadUserValues(userId);
    await _weekValueDao.loadUserValues(userId);
  }

  static bool isWeekClosed(
    List<WeekValue> weekValues,
    DateTime weekStartDate,
  ) =>
      weekValues.any((week) =>
          week.weekStartDate == weekStartDate ||
          week.weekStartDate.isAfter(weekStartDate));

  Future<void> updateDaysOfWeek(List<DayValue> values) =>
      runContextDependentAction(
        _userService.currentUserStream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) => validateAndRun(
          _getDaysUpdateValidator(values),
          () async {
            for (final day in values) {
              await _dayValueDao.upsert(user.id, day);
            }
          },
        ),
      );

  Future<void> onReset(DayValue oldDayValue) => runContextDependentAction(
        _userService.currentUserStream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) => validateAndRun(
          _getWeekNotAlreadyClosedValidator(oldDayValue.date.firstDayOfWeek),
          () => _dayValueDao.deleteByUserIdAndDate(user.id, oldDayValue.date),
        ),
      );

  Future<void> updateWorkTime(
    DayValue oldDayValue,
    ({
      int workTimeStart,
      int workTimeEnd,
    }) workTime,
  ) =>
      _updateDayOfWeek(DayValue(
        date: oldDayValue.date,
        workTimeStart: workTime.workTimeStart,
        workTimeEnd: workTime.workTimeEnd,
        breakDuration: oldDayValue.breakDuration,
        firstHalfMode: oldDayValue.firstHalfMode,
        secondHalfMode: oldDayValue.secondHalfMode,
      ));

  Future<void> updateBreakDuration(
    DayValue oldDayValue,
    int breakDuration,
  ) =>
      _updateDayOfWeek(DayValue(
        date: oldDayValue.date,
        workTimeStart: oldDayValue.workTimeStart,
        workTimeEnd: oldDayValue.workTimeEnd,
        breakDuration: breakDuration,
        firstHalfMode: oldDayValue.firstHalfMode,
        secondHalfMode: oldDayValue.secondHalfMode,
      ));

  Future<void> updateFirstHalfMode(
    DayValue oldDayValue,
    DayMode firstHalfMode,
  ) =>
      runContextDependentAction(
        _weekSettingService.weekSettingStream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (weekSettings) {
          final isNotAWorkDay = oldDayValue.secondHalfMode != DayMode.workDay &&
              firstHalfMode != DayMode.workDay;
          final becameWorkDay = oldDayValue.firstHalfMode != DayMode.workDay &&
              oldDayValue.secondHalfMode != DayMode.workDay &&
              firstHalfMode == DayMode.workDay;
          final becameFullWorkDay =
              oldDayValue.firstHalfMode != DayMode.workDay &&
                  oldDayValue.secondHalfMode == DayMode.workDay &&
                  firstHalfMode == DayMode.workDay;
          final defaultValues = weekSettings
              .weekDaySettings[DayOfWeek.fromDateTime(oldDayValue.date)];
          return _updateDayOfWeek(DayValue(
            date: oldDayValue.date,
            workTimeStart: isNotAWorkDay
                ? 0
                : becameWorkDay
                    ? defaultValues?.defaultWorkTimeStart ?? 0
                    : becameFullWorkDay
                        ? min(
                            defaultValues?.mandatoryWorkTimeStart ?? 0,
                            oldDayValue.workTimeStart,
                          )
                        : oldDayValue.workTimeStart,
            workTimeEnd: isNotAWorkDay
                ? 0
                : becameWorkDay
                    ? defaultValues?.defaultWorkTimeEnd ?? 0
                    : becameFullWorkDay
                        ? max(
                            defaultValues?.mandatoryWorkTimeEnd ?? 0,
                            oldDayValue.workTimeEnd,
                          )
                        : oldDayValue.workTimeEnd,
            breakDuration: isNotAWorkDay
                ? 0
                : becameWorkDay
                    ? defaultValues?.defaultBreakDuration ?? 0
                    : oldDayValue.breakDuration,
            firstHalfMode: firstHalfMode,
            secondHalfMode: oldDayValue.secondHalfMode,
          ));
        },
      );

  Future<void> updateSecondHalfMode(
    DayValue oldDayValue,
    DayMode secondHalfMode,
  ) =>
      runContextDependentAction(
        _weekSettingService.weekSettingStream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (weekSettings) {
          final isNotAWorkDay = oldDayValue.firstHalfMode != DayMode.workDay &&
              secondHalfMode != DayMode.workDay;
          final becameWorkDay = oldDayValue.firstHalfMode != DayMode.workDay &&
              oldDayValue.secondHalfMode != DayMode.workDay &&
              secondHalfMode == DayMode.workDay;
          final becameFullWorkDay =
              oldDayValue.firstHalfMode == DayMode.workDay &&
                  oldDayValue.secondHalfMode != DayMode.workDay &&
                  secondHalfMode == DayMode.workDay;
          final defaultValues = weekSettings
              .weekDaySettings[DayOfWeek.fromDateTime(oldDayValue.date)];
          return _updateDayOfWeek(DayValue(
            date: oldDayValue.date,
            workTimeStart: isNotAWorkDay
                ? 0
                : becameWorkDay
                    ? defaultValues?.defaultWorkTimeStart ?? 0
                    : becameFullWorkDay
                        ? min(
                            defaultValues?.mandatoryWorkTimeStart ?? 0,
                            oldDayValue.workTimeStart,
                          )
                        : oldDayValue.workTimeStart,
            workTimeEnd: isNotAWorkDay
                ? 0
                : becameWorkDay
                    ? defaultValues?.defaultWorkTimeEnd ?? 0
                    : becameFullWorkDay
                        ? max(
                            defaultValues?.mandatoryWorkTimeEnd ?? 0,
                            oldDayValue.workTimeEnd,
                          )
                        : oldDayValue.workTimeEnd,
            breakDuration: isNotAWorkDay
                ? 0
                : becameWorkDay
                    ? defaultValues?.defaultBreakDuration ?? 0
                    : oldDayValue.breakDuration,
            firstHalfMode: oldDayValue.firstHalfMode,
            secondHalfMode: secondHalfMode,
          ));
        },
      );

  Future<void> _updateDayOfWeek(DayValue value) => runContextDependentAction(
        _userService.currentUserStream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) => validateAndRun(
          _getDayUpdateValidator(value),
          () async => _dayValueDao.upsert(user.id, value),
        ),
      );

  Future<void> closeWeek(
    DateTime weekStartDate,
    List<DayValue> dayValues,
    bool isConfirmed,
  ) =>
      runContextDependentAction(
        _userService.currentUserStream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) async {
          // save all days in this week
          await updateDaysOfWeek(dayValues);
          // close the week
          await runContextDependentAction(
            _weekSettingService.weekSettingStream.state,
            () async => Future.error(AppError.service_noUserLoaded),
            (weekSetting) => validateAndRun(
              getIsWeekClosableValidator(weekStartDate) +
                  getIsConfirmedValidator(
                    isConfirmed,
                    AppError.service_timeInput_unconfirmedClose,
                  ),
              () => _weekValueDao
                  .create(
                    user.id,
                    WeekValue(
                      weekStartDate: weekStartDate,
                      targetTime: _weekValueService.getActualTargetTimeOfWeek(
                        weekSetting,
                        dayValues,
                      ),
                    ),
                  )
                  // move events (this is done with a then-statement as transaction safety is not critical here)
                  .then(
                    (_) => _eventSettingService
                        .movePastEventsToNearestFutureOccurrence(
                      weekStartDate,
                    ),
                  ),
            ),
          );
        },
      );

  @override
  void close() {
    super.close();
    _userService.close();
    _weekSettingService.close();
    _eventSettingService.close();
  }
}
