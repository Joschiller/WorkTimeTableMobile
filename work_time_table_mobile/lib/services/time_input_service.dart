import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/day_value_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/daos/week_value_dao.dart';
import 'package:work_time_table_mobile/models/event_setting/day_based_repetition_rule.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/event_type.dart';
import 'package:work_time_table_mobile/models/event_setting/month_based_repetition_rule.dart';
import 'package:work_time_table_mobile/models/value/day_mode.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/context/list/context_dependent_list_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/identifiable.dart';
import 'package:work_time_table_mobile/stream_helpers/streamable_service.dart';
import 'package:work_time_table_mobile/utils.dart';

class WeekInformation implements Identifiable {
  final DateTime weekStartDate;
  final int resultOfPredecessorWeek;
  final Map<DayOfWeek, DayValue> days;
  final int weekResult;
  final bool weekClosed;

  WeekInformation({
    required this.weekStartDate,
    required this.resultOfPredecessorWeek,
    required this.days,
    required this.weekResult,
    required this.weekClosed,
  });

  @override
  get identity => weekStartDate;
}

typedef MergedDaoValues = ({
  WeekSetting weekSetting,
  List<EventSetting> eventSettings,
  List<DayValue> dayValues,
  List<WeekValue> weekValues,
});

final _weekSettingStream = ContextDependentStream<WeekSetting>();
final _eventSettingStream = ContextDependentListStream<EventSetting>();
final _dayValueStream = ContextDependentListStream<DayValue>();
final _weekValueStream = ContextDependentListStream<WeekValue>();

class TimeInputService extends StreamableService {
  TimeInputService(
    this._currentUserDao,
    this._weekSettingDao,
    this._eventSettingDao,
    this._dayValueDao,
    this._weekValueDao,
  ) {
    _currentUserDao.stream.stream
        .listen((selectedUser) => runContextDependentAction(
              selectedUser,
              () => _loadData(null),
              (user) => _loadData(user.id),
            ));
    prepareListen(_weekSettingDao.stream, _weekSettingStream);
    prepareListen(_eventSettingDao.stream, _eventSettingStream);
    prepareListen(_dayValueDao.stream, _dayValueStream);
    prepareListen(_weekValueDao.stream, _weekValueStream);
  }

  final CurrentUserDao _currentUserDao;
  final WeekSettingDao _weekSettingDao;
  final EventSettingDao _eventSettingDao;
  final DayValueDao _dayValueDao;
  final WeekValueDao _weekValueDao;

  Stream<ContextDependentValue<WeekSetting>> get weekSettingStream =>
      _weekSettingStream.stream;
  Stream<ContextDependentValue<List<EventSetting>>> get eventSettingStream =>
      _eventSettingStream.stream;
  Stream<ContextDependentValue<List<DayValue>>> get dayValueStream =>
      _dayValueStream.stream;
  Stream<ContextDependentValue<List<WeekValue>>> get weekValueStream =>
      _weekValueStream.stream;

  ContextDependentValue<WeekInformation> getValuesForWeek(
    DateTime weekStartDate,
  ) =>
      switch (_getValuesFromDaos()) {
        NoContextValue() => NoContextValue(),
        ContextValue(value: var values) => ContextValue(_getValuesForWeek(
            weekStartDate,
            values,
          )),
      };

  ContextDependentValue<MergedDaoValues> _getValuesFromDaos() =>
      switch (_weekSettingDao.stream.state) {
        NoContextValue() => NoContextValue(),
        ContextValue(value: var weekSetting) => switch (
              _eventSettingDao.stream.state) {
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

  WeekInformation _getValuesForWeek(
    DateTime weekStartDate,
    MergedDaoValues values,
  ) {
    // week value
    final week = values.weekValues
        .where((week) => week.weekStartDate == weekStartDate)
        .firstOrNull;

    // day values
    final days = <DayOfWeek, DayValue>{};
    for (final dayOfWeek in DayOfWeek.values) {
      final dateOfDay = weekStartDate.add(Duration(days: dayOfWeek.index));
      days[dayOfWeek] =
          // stored value
          (values.dayValues
                  .where((day) => day.date == dateOfDay)
                  .firstOrNull) ??
              _getInitialValueForDay(
                dateOfDay,
                values.weekSetting,
                values.eventSettings,
              );
    }
    final resultOfPredecessorWeek = values.dayValues
            .where((day) => day.date.isBefore(weekStartDate))
            .map((day) =>
                day.workTimeEnd - day.workTimeStart - day.breakDuration)
            .reduce((a, b) => a + b) -
        values.weekValues
            .where((week) => week.weekStartDate.isBefore(weekStartDate))
            .map((week) => week.targetTime)
            .reduce((a, b) => a + b);
    // TODO: theoretically needs to also substract all target values for the unsaved week sbefore the current week, but this may be a theoretical scenario
    return WeekInformation(
      weekStartDate: weekStartDate,
      resultOfPredecessorWeek: resultOfPredecessorWeek,
      days: days,
      weekResult: resultOfPredecessorWeek +
          days.values
              .map((day) =>
                  day.workTimeEnd - day.workTimeStart - day.breakDuration)
              .reduce((a, b) => a + b) -
          (week?.targetTime ?? values.weekSetting.targetWorkTimePerWeek),
      weekClosed: week != null,
    );
  }

  DayValue _getInitialValueForDay(
    DateTime date,
    WeekSetting weekSetting,
    List<EventSetting> eventSettings,
  ) {
    final daySetting =
        weekSetting.weekDaySettings[DayOfWeek.fromDateTime(date)];

    // if nonWorkDay -> nonWorkDay
    if (daySetting == null) {
      return DayValue(
        date: date,
        firstHalfMode: DayMode.nonWorkDay,
        secondHalfMode: DayMode.nonWorkDay,
        workTimeStart: 0,
        workTimeEnd: 0,
        breakDuration: 0,
      );
    }

    // check if any event is set for part of the day
    var modeForFirstHalfOfDay = DayMode.workDay;
    var modeForSecondHalfOfDay = DayMode.workDay;

    for (final eventType in EventType.values
      ..sort((a, b) => a.priority - b.priority)) {
      for (final event
          in eventSettings.where((event) => event.eventType == eventType)) {
        // check event range
        final eventInfluence = _doesEventAffectDate(date, event);

        if (eventInfluence.firstHalf &&
            modeForFirstHalfOfDay == DayMode.workDay) {
          modeForFirstHalfOfDay = DayMode.fromEventType(event.eventType);
        }

        if (eventInfluence.secondHalf &&
            modeForSecondHalfOfDay == DayMode.workDay) {
          modeForSecondHalfOfDay = DayMode.fromEventType(event.eventType);
        }

        if (modeForFirstHalfOfDay != DayMode.workDay &&
            modeForSecondHalfOfDay != DayMode.workDay) {
          break;
        }
      }

      if (modeForFirstHalfOfDay != DayMode.workDay &&
          modeForSecondHalfOfDay != DayMode.workDay) {
        break;
      }
    }

    if (modeForFirstHalfOfDay != DayMode.workDay &&
        modeForSecondHalfOfDay != DayMode.workDay) {
      // found a non working day
      return DayValue(
        date: date,
        firstHalfMode: modeForFirstHalfOfDay,
        secondHalfMode: modeForSecondHalfOfDay,
        workTimeStart: 0,
        workTimeEnd: 0,
        breakDuration: 0,
      );
    }

    // built up day value respecting default and core time if necessary
    return DayValue(
      date: date,
      firstHalfMode: modeForFirstHalfOfDay,
      secondHalfMode: modeForSecondHalfOfDay,
      workTimeStart: daySetting.defaultWorkTimeStart ??
          weekSetting.globalWeekDaySetting.defaultWorkTimeStart,
      workTimeEnd: daySetting.defaultWorkTimeEnd ??
          weekSetting.globalWeekDaySetting.defaultWorkTimeEnd,
      breakDuration: daySetting.defaultBreakDuration ??
          weekSetting.globalWeekDaySetting.defaultBreakDuration,
    );
  }

  ({bool firstHalf, bool secondHalf}) _doesEventAffectDate(
      DateTime targetDate, EventSetting event) {
    var firstHalf = false;
    var secondHalf = false;
    // check event base values
    final eventRangeCheck = _isDateInRange(targetDate, (
      start: event.startDate,
      end: event.endDate,
      startIsHalfDay: event.startIsHalfDay,
      endIsHalfDay: event.endIsHalfDay,
    ));
    firstHalf = firstHalf || eventRangeCheck.firstHalf;
    secondHalf = secondHalf || eventRangeCheck.secondHalf;

    final eventDuration = DateTimeRange(
      start: event.startDate,
      end: event.endDate,
    ).duration;

    // check repetitions
    for (final daybasedRepetition in event.dayBasedRepetitionRules) {
      var currentStartDate = _getNextOccurenceOfDayBasedRepetition(
        event.startDate,
        daybasedRepetition,
      );
      while (!targetDate.isBefore(currentStartDate)) {
        // check range
        final eventRangeCheck = _isDateInRange(targetDate, (
          start: currentStartDate,
          end: currentStartDate.add(eventDuration),
          startIsHalfDay: event.startIsHalfDay,
          endIsHalfDay: event.endIsHalfDay,
        ));
        firstHalf = firstHalf || eventRangeCheck.firstHalf;
        secondHalf = secondHalf || eventRangeCheck.secondHalf;

        currentStartDate = _getNextOccurenceOfDayBasedRepetition(
          currentStartDate,
          daybasedRepetition,
        );
      }
    }
    for (final monthBasedRepetitions in event.monthBasedRepetitionRules) {
      var currentStartDate = _getNextOccurenceOfMonthBasedRepetition(
        event.startDate,
        monthBasedRepetitions,
      );
      while (!targetDate.isBefore(currentStartDate)) {
        // check range
        final eventRangeCheck = _isDateInRange(targetDate, (
          start: currentStartDate,
          end: currentStartDate.add(eventDuration),
          startIsHalfDay: event.startIsHalfDay,
          endIsHalfDay: event.endIsHalfDay,
        ));
        firstHalf = firstHalf || eventRangeCheck.firstHalf;
        secondHalf = secondHalf || eventRangeCheck.secondHalf;

        currentStartDate = _getNextOccurenceOfMonthBasedRepetition(
          currentStartDate,
          monthBasedRepetitions,
        );
      }
    }

    return (firstHalf: firstHalf, secondHalf: secondHalf);
  }

  DateTime _getNextOccurenceOfDayBasedRepetition(
    DateTime currentDate,
    DayBasedRepetitionRule repetition,
  ) =>
      currentDate.add(Duration(
        days: repetition.repeatAfterDays,
      ));

  DateTime _getNextOccurenceOfMonthBasedRepetition(
    DateTime currentDate,
    MonthBasedRepetitionRule repetition,
  ) {
    final targetMonth = DateTime(
      currentDate.year,
      currentDate.month + repetition.repeatAfterMonths,
    );
    final countOfDaysInMonth = DateTimeRange(
      start: targetMonth,
      end: DateTime(targetMonth.year, targetMonth.month + 1),
    ).duration.inDays;

    final weekIndex = repetition.weekIndex;

    if (weekIndex == null) {
      return DateTime(
        targetMonth.year,
        targetMonth.month,
        repetition.countFromEnd
            ? countOfDaysInMonth - repetition.dayIndex
            : repetition.dayIndex + 1,
      );
    } else {
      final instancesOfDayOfWeek = <DateTime>[];
      for (var i = 0; i < countOfDaysInMonth; i++) {
        final dayToTest = targetMonth.add(Duration(days: i));
        if (DayOfWeek.fromDateTime(dayToTest) ==
                DayOfWeek.values[repetition.dayIndex]
            // check hours for some special cases (e.g. searching for sundays in 10/2024)
            &&
            dayToTest.hour == 0) {
          instancesOfDayOfWeek.add(dayToTest);
        }
      }
      return instancesOfDayOfWeek[repetition.countFromEnd
          ? instancesOfDayOfWeek.length - weekIndex - 1
          : weekIndex];
    }
  }

  ({bool firstHalf, bool secondHalf}) _isDateInRange(
      DateTime targetDate,
      ({
        DateTime start,
        DateTime end,
        bool startIsHalfDay,
        bool endIsHalfDay,
      }) range) {
    if (!targetDate.isBefore(range.start) && !targetDate.isAfter(range.end)) {
      final firstHalf =
          !range.startIsHalfDay || range.start.isBefore(targetDate);
      final secondHalf = !range.endIsHalfDay || range.end.isAfter(targetDate);
      return (firstHalf: firstHalf, secondHalf: secondHalf);
    }
    return (firstHalf: false, secondHalf: false);
  }

  static DateTime getStartDateOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  Future<void> _loadData(int? userId) async {
    await _dayValueDao.loadUserValues(userId);
    await _weekValueDao.loadUserValues(userId);
  }

  static bool isWeekClosed(
    List<WeekValue> weekValues,
    DateTime weekStartDate,
  ) =>
      weekValues.any((week) => week.weekStartDate == weekStartDate);

  Future<void> updateDaysOfWeek(List<DayValue> values) =>
      runContextDependentAction(
        _currentUserDao.stream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) => validateAndRun(
          [
            // 7 consecutive days, starting with monday
            () =>
                values.length != 7 ? AppError.service_timeInput_invalid : null,
            () => values.asMap().entries.any(
                    (element) => element.key + 1 != element.value.date.weekday)
                ? AppError.service_timeInput_invalid
                : null,
            // week not already closed
            () => runContextDependentAction(
                  _weekValueDao.stream.state,
                  () => null,
                  (weekValues) => isWeekClosed(weekValues, values.first.date)
                      ? AppError.service_timeInput_alreadyClosed
                      : null,
                ),
            // empty values if completely not workDay
            () => values.any((day) =>
                    day.firstHalfMode != DayMode.workDay &&
                    day.secondHalfMode != DayMode.workDay &&
                    (day.workTimeStart != 0 ||
                        day.workTimeEnd != 0 ||
                        day.breakDuration != 0))
                ? AppError.service_timeInput_invalid
                : null,
            // start <= end
            () => values.any((day) => day.workTimeStart > day.workTimeEnd)
                ? AppError.service_timeInput_invalid
                : null,
            // settings dependent validations
            () => runContextDependentAction(
                  _weekSettingDao.stream.state,
                  () => AppError.service_noUserLoaded,
                  (weekSettings) => validateAndRun(
                    [
                      () => values.any((day) {
                            final settingForDay = weekSettings.weekDaySettings[
                                DayOfWeek.fromDateTime(day.date)];
                            if (settingForDay == null) {
                              // configured nonWorkDays are stored as nonWorkDays
                              return day.firstHalfMode != DayMode.nonWorkDay ||
                                  day.secondHalfMode != DayMode.nonWorkDay;
                            }

                            // work time respects manatory time start
                            if (day.firstHalfMode == DayMode.workDay &&
                                (day.workTimeStart >
                                    (settingForDay.mandatoryWorkTimeStart ??
                                        weekSettings.globalWeekDaySetting
                                            .defaultMandatoryWorkTimeStart))) {
                              return true;
                            }
                            // work time respects manatory time end
                            if (day.secondHalfMode == DayMode.workDay &&
                                (day.workTimeEnd <
                                    (settingForDay.mandatoryWorkTimeEnd ??
                                        weekSettings.globalWeekDaySetting
                                            .defaultMandatoryWorkTimeEnd))) {
                              return true;
                            }
                            return false;
                          })
                              ? AppError.service_timeInput_invalid
                              : null,
                    ],
                    // settings are respected
                    () => null,
                  ),
                ),
          ],
          () async {
            for (final day in values) {
              await _dayValueDao.upsert(user.id, day);
            }
          },
        ),
      );

  Future<void> resetDaysOfWeek(DateTime weekStartDate, bool isConfirmed) =>
      runContextDependentAction(
        _currentUserDao.stream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) => validateAndRun(
          [
            // weekStartDate is a monday
            () => DayOfWeek.fromDateTime(weekStartDate) != DayOfWeek.monday
                ? AppError.service_timeInput_invalid
                : null,
            // week not already closed
            () => runContextDependentAction(
                  _weekValueDao.stream.state,
                  () => null,
                  (weekValues) => isWeekClosed(weekValues, weekStartDate)
                      ? AppError.service_timeInput_alreadyClosed
                      : null,
                ),
            // unconfirmed
            () => !isConfirmed
                ? AppError.service_timeInput_unconfirmedReset
                : null,
          ],
          () => _dayValueDao.deleteByUserIdAndDates(
            user.id,
            List.generate(7, (i) => weekStartDate.add(Duration(days: i))),
          ),
        ),
      );

  Future<void> closeWeek(
    WeekValue value,
    List<DayValue> dayValues,
    bool isConfirmed,
  ) =>
      runContextDependentAction(
        _currentUserDao.stream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) async {
          // save all days in this week
          await updateDaysOfWeek(dayValues);
          // close the week
          await validateAndRun(
            [
              // weekStartDate is a monday
              () => DayOfWeek.fromDateTime(value.weekStartDate) !=
                      DayOfWeek.monday
                  ? AppError.service_timeInput_invalid
                  : null,
              // week not already closed
              () => runContextDependentAction(
                    _weekValueDao.stream.state,
                    () => null,
                    (weekValues) =>
                        isWeekClosed(weekValues, value.weekStartDate)
                            ? AppError.service_timeInput_alreadyClosed
                            : null,
                  ),
              // unconfirmed
              () => !isConfirmed
                  ? AppError.service_timeInput_unconfirmedClose
                  : null,
            ],
            () => _weekValueDao.create(user.id, value),
          );
        },
      );
}
