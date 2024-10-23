import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/day_value_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/daos/week_value_dao.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/value/day_mode.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/day_value_service.dart';
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
    this._dayValueService,
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
  final DayValueService _dayValueService;

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
              _dayValueService.getInitialValueForDay(
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
