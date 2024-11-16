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
              () => _loadData(null),
              (user) => _loadData(user.id),
            )));
    prepareListen(_dayValueDao.stream, _dayValueStream);
    prepareListen(_weekValueDao.stream, _weekValueStream);
  }

  final UserService _userService;
  final WeekSettingService _weekSettingService;
  final EventSettingService _eventSettingService;
  final DayValueDao _dayValueDao;
  final WeekValueDao _weekValueDao;
  final WeekValueService _weekValueService;

  ContextDependentListStream<DayValue> get dayValueStream => _dayValueStream;
  ContextDependentListStream<WeekValue> get weekValueStream => _weekValueStream;

  Validator _getDayUpdateValidator(List<DayValue> values) => Validator([
        // 7 consecutive days, starting with monday
        () => values.length != 7 ? AppError.service_timeInput_invalid : null,
        () => values
                .asMap()
                .entries
                .any((element) => element.key + 1 != element.value.date.weekday)
            ? AppError.service_timeInput_invalid
            : null,
        // week not already closed
        () => _getWeekNotAlreadyClosedValidator(values.first.date).validate(),
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
              _weekSettingService.weekSettingStream.state,
              () => AppError.service_noUserLoaded,
              (weekSettings) =>
                  _getDayValueAgainstSettingsValidator(values, weekSettings)
                      .validate(),
            ),
      ]);

  Validator _getDayValueAgainstSettingsValidator(
    List<DayValue> values,
    WeekSetting weekSettings,
  ) =>
      Validator([
        () => values.any((day) {
              final settingForDay = weekSettings
                  .weekDaySettings[DayOfWeek.fromDateTime(day.date)];
              if (settingForDay == null) {
                // configured nonWorkDays are stored as nonWorkDays
                return day.firstHalfMode != DayMode.nonWorkDay ||
                    day.secondHalfMode != DayMode.nonWorkDay;
              }

              // work time respects manatory time start
              if (day.firstHalfMode == DayMode.workDay &&
                  (day.workTimeStart > settingForDay.mandatoryWorkTimeStart)) {
                return true;
              }
              // work time respects manatory time end
              if (day.secondHalfMode == DayMode.workDay &&
                  (day.workTimeEnd < settingForDay.mandatoryWorkTimeEnd)) {
                return true;
              }
              return false;
            })
                ? AppError.service_timeInput_invalid
                : null,
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
        _userService.currentUserStream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) => validateAndRun(
          _getDayUpdateValidator(values),
          () async {
            for (final day in values) {
              await _dayValueDao.upsert(user.id, day);
            }
          },
        ),
      );

  Future<void> resetDaysOfWeek(DateTime weekStartDate, bool isConfirmed) =>
      runContextDependentAction(
        _userService.currentUserStream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) => validateAndRun(
          _getWeekStartIsMondayValidator(weekStartDate) +
              _getWeekNotAlreadyClosedValidator(weekStartDate) +
              getIsConfirmedValidator(
                isConfirmed,
                AppError.service_timeInput_unconfirmedReset,
              ),
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
        _userService.currentUserStream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) async {
          // save all days in this week
          await updateDaysOfWeek(dayValues);
          // close the week
          await validateAndRun(
            _getWeekStartIsMondayValidator(value.weekStartDate) +
                _getWeekNotAlreadyClosedValidator(value.weekStartDate) +
                _getHasOneDayOfWeekPassedValidator(value.weekStartDate) +
                getIsConfirmedValidator(
                  isConfirmed,
                  AppError.service_timeInput_unconfirmedClose,
                ),
            () => _weekValueDao.create(user.id, value),
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
