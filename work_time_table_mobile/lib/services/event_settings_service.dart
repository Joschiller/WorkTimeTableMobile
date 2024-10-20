import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/models/event_setting/day_based_repetition_rule.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/month_based_repetition_rule.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/user_dependent_value.dart';
import 'package:work_time_table_mobile/utils.dart';

class EventSettingsService {
  EventSettingsService(this.currentUserDao, this.eventSettingDao) {
    currentUserDao.stream.listen((selectedUser) => runUserDependentAction(
          selectedUser,
          () => _loadData(null),
          (user) => _loadData(user.id),
        ));
  }

  final CurrentUserDao currentUserDao;
  final EventSettingDao eventSettingDao;

  Future<void> _loadData(int? userId) =>
      eventSettingDao.loadUserSettings(userId);

  // TODO: "getEventForDaTe" -> checks all events for that day and returns the correct value

  Future<void> addEvent(EventSetting event) => runUserDependentAction(
        currentUserDao.data,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) => validateAndRun(
          [
            // start <= end
            () => event.startDate.isAfter(event.endDate)
                ? AppError.service_eventSettings_invalid
                : null,
            // non-empty event
            () => event.startDate == event.endDate &&
                    event.startIsHalfDay &&
                    event.endIsHalfDay
                ? AppError.service_eventSettings_invalid
                : null,
            // repetitions valid
            () => event.dayBasedRepetitionRules
                    .any((rule) => !_isDayBasedRepetitionRuleValid(rule))
                ? AppError.service_eventSettings_invalid
                : null,
            () => event.monthBasedRepetitionRules
                    .any((rule) => !_isMonthBasedRepetitionRuleValid(rule))
                ? AppError.service_eventSettings_invalid
                : null,
          ],
          () => eventSettingDao.create(user.id, event),
        ),
      );

  Future<void> deleteEvent(int id, bool isConfirmed) => validateAndRun([
        () => !isConfirmed
            ? AppError.service_eventSettings_unconfirmedDeletion
            : null,
      ], () => eventSettingDao.deleteById(id));
}

bool _isDayBasedRepetitionRuleValid(DayBasedRepetitionRule rule) =>
    rule.repeatAfterDays > 0;

bool _isMonthBasedRepetitionRuleValid(MonthBasedRepetitionRule rule) {
  if (rule.repeatAfterMonths <= 0) {
    return false;
  }
  if (rule.dayIndex < 0) {
    return false;
  }
  if ((rule.weekIndex ?? 0) < 0) {
    return false;
  }

  if ((rule.weekIndex ?? 0) >= 4) {
    return false;
  }
  if (rule.weekIndex != null && rule.dayIndex >= 7) {
    return false;
  }
  if (rule.weekIndex == null && rule.dayIndex >= 28) {
    return false;
  }

  return true;
}
