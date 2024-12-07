import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/models/event_setting/day_based_repetition_rule.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/month_based_repetition_rule.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/context/list/context_dependent_list_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/streamable_service.dart';
import 'package:work_time_table_mobile/validate_and_run.dart';
import 'package:work_time_table_mobile/validator.dart';

final _stream = ContextDependentListStream<EventSetting>();

class EventSettingService extends StreamableService {
  EventSettingService(this._userService, this._eventSettingDao) {
    registerSubscription(_userService.currentUserStream.stream
        .listen((selectedUser) => runContextDependentAction(
              selectedUser,
              () => _loadData(null),
              (user) => _loadData(user.id),
            )));
    prepareListen(_eventSettingDao.stream, _stream);
    runContextDependentAction(
      _userService.currentUserStream.state,
      () => _loadData(null),
      (user) => _loadData(user.id),
    );
  }

  final UserService _userService;
  final EventSettingDao _eventSettingDao;

  Validator _getEventValidator(EventSetting event) => Validator([
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
      ]);

  ContextDependentListStream<EventSetting> get eventSettingStream => _stream;

  Future<void> _loadData(int? userId) =>
      _eventSettingDao.loadUserSettings(userId);

  Future<void> addEvent(EventSetting event) => runContextDependentAction(
        _userService.currentUserStream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) => validateAndRun(
          _getEventValidator(event),
          () => _eventSettingDao.create(user.id, event),
        ),
      );

  Future<void> deleteEvent(int id, bool isConfirmed) => validateAndRun(
      getIsConfirmedValidator(
        isConfirmed,
        AppError.service_eventSettings_unconfirmedDeletion,
      ),
      () => _eventSettingDao.deleteById(id));

  @override
  close() {
    super.close();
    _userService.close();
  }
}

bool _isDayBasedRepetitionRuleValid(DayBasedRepetitionRule rule) =>
    rule.repeatAfterDays > 0;

bool _isMonthBasedRepetitionRuleValid(MonthBasedRepetitionRule rule) {
  if (rule.repeatAfterMonths <= 0) {
    return false;
  }
  if (rule.monthBasedRepetitionRuleBase.dayIndex < 0) {
    return false;
  }
  if ((rule.monthBasedRepetitionRuleBase.weekIndex ?? 0) < 0) {
    return false;
  }

  if ((rule.monthBasedRepetitionRuleBase.weekIndex ?? 0) >= 4) {
    return false;
  }
  if (rule.monthBasedRepetitionRuleBase.weekIndex != null &&
      rule.monthBasedRepetitionRuleBase.dayIndex >= 7) {
    return false;
  }
  if (rule.monthBasedRepetitionRuleBase.weekIndex == null &&
      rule.monthBasedRepetitionRuleBase.dayIndex >= 28) {
    return false;
  }

  return true;
}
