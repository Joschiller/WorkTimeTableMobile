import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/models/event_setting/day_based_repetition_rule.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/month_based_repetition_rule.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/context/list/context_dependent_list_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/streamable_service.dart';
import 'package:work_time_table_mobile/utils.dart';

final _stream = ContextDependentListStream<EventSetting>();

class EventSettingService extends StreamableService {
  EventSettingService(this._currentUserDao, this._eventSettingDao) {
    _currentUserDao.stream.listen((selectedUser) => runContextDependentAction(
          selectedUser,
          () => _loadData(null),
          (user) => _loadData(user.id),
        ));
    prepareListen(_eventSettingDao, _stream);
  }

  final CurrentUserDao _currentUserDao;
  final EventSettingDao _eventSettingDao;

  Stream<ContextDependentValue<List<EventSetting>>> get weekSettingStream =>
      _stream.stream;

  Future<void> _loadData(int? userId) =>
      _eventSettingDao.loadUserSettings(userId);

  // TODO: "getEventForDaTe" -> checks all events for that day and returns the correct value

  Future<void> addEvent(EventSetting event) => runContextDependentAction(
        _currentUserDao.data,
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
          () => _eventSettingDao.create(user.id, event),
        ),
      );

  Future<void> deleteEvent(int id, bool isConfirmed) => validateAndRun([
        () => !isConfirmed
            ? AppError.service_eventSettings_unconfirmedDeletion
            : null,
      ], () => _eventSettingDao.deleteById(id));
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
