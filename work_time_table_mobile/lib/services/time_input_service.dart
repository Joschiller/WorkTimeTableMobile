import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/day_value_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/daos/week_value_dao.dart';
import 'package:work_time_table_mobile/models/value/day_mode.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/utils.dart';

class TimeInputService {
  TimeInputService(
    this.currentUserDao,
    this.weekSettingDao,
    this.eventSettingDao,
    this.dayValueDao,
    this.weekValueDao,
  ) {
    currentUserDao.stream.listen((selectedUser) => runContextDependentAction(
          selectedUser,
          () => _loadData(null),
          (user) => _loadData(user.id),
        ));
  }

  final CurrentUserDao currentUserDao;
  final WeekSettingDao weekSettingDao;
  final EventSettingDao eventSettingDao;
  final DayValueDao dayValueDao;
  final WeekValueDao weekValueDao;

  Future<void> _loadData(int? userId) async {
    await dayValueDao.loadUserValues(userId);
    await weekValueDao.loadUserValues(userId);
  }

  // TODO: "getDefaultValueForDate" -> checks all events for that day and returns the correct value as well as setting the default work times

  static bool isWeekClosed(
    List<WeekValue> weekValues,
    DateTime weekStartDate,
  ) =>
      weekValues.any((week) => week.weekStartDate == weekStartDate);

  Future<void> updateDaysOfWeek(List<DayValue> values) =>
      runContextDependentAction(
        currentUserDao.data,
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
                  weekValueDao.data,
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
                  weekSettingDao.data,
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
              await dayValueDao.upsert(user.id, day);
            }
          },
        ),
      );

  Future<void> resetDaysOfWeek(DateTime weekStartDate, bool isConfirmed) =>
      runContextDependentAction(
        currentUserDao.data,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) => validateAndRun(
          [
            // weekStartDate is a monday
            () => DayOfWeek.fromDateTime(weekStartDate) != DayOfWeek.monday
                ? AppError.service_timeInput_invalid
                : null,
            // week not already closed
            () => runContextDependentAction(
                  weekValueDao.data,
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
          () => dayValueDao.deleteByUserIdAndDates(
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
        currentUserDao.data,
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
                    weekValueDao.data,
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
            () => weekValueDao.create(user.id, value),
          );
        },
      );
}
