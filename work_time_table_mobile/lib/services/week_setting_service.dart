import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/streamable_service.dart';
import 'package:work_time_table_mobile/validate_and_run.dart';
import 'package:work_time_table_mobile/validator.dart';

final _stream = ContextDependentStream<WeekSetting>();

class WeekSettingService extends StreamableService {
  WeekSettingService(this._userService, this._weekSettingDao) {
    registerSubscription(_userService.currentUserStream.stream
        .listen((selectedUser) => runContextDependentAction(
              selectedUser,
              () => _loadData(null),
              (user) => _loadData(user.id),
            )));
    prepareListen(_weekSettingDao.stream, _stream);
    runContextDependentAction(
      _userService.currentUserStream.state,
      () => _loadData(null),
      (user) => _loadData(user.id),
    );
  }

  final UserService _userService;
  final WeekSettingDao _weekSettingDao;

  static final Validator<WeekSetting> weekSettingsValidator = Validator([
    // targetWorkTimePerWeek <= SUM(timeEquivalent)
    (settings) => settings.targetWorkTimePerWeek >
            (settings.weekDaySettings.values.isEmpty
                ? 0
                : settings.weekDaySettings.values
                    .map((s) => s.timeEquivalent)
                    .reduce((a, b) => a + b))
        ? AppError.service_weekSettings_invalidTargetWorktime
        : null,
    // each day of week is unique -> technical validation
    (settings) => settings.weekDaySettings.entries
            .any((day) => day.key != day.value.dayOfWeek)
        ? AppError.service_weekSettings_invalid
        : null,
    // start <= end -> technical validation
    (settings) => settings.weekDaySettings.values
            .any((day) => day.defaultWorkTimeStart > day.defaultWorkTimeEnd)
        ? AppError.service_weekSettings_invalid
        : null,
    (settings) => settings.weekDaySettings.values
            .any((day) => day.mandatoryWorkTimeStart > day.mandatoryWorkTimeEnd)
        ? AppError.service_weekSettings_invalid
        : null,
    // default time respects manatory time -> technical validation
    (settings) => settings.weekDaySettings.values
            .any((day) => day.defaultWorkTimeStart > day.mandatoryWorkTimeStart)
        ? AppError.service_weekSettings_invalid
        : null,
    (settings) => settings.weekDaySettings.values
            .any((day) => day.defaultWorkTimeEnd < day.mandatoryWorkTimeEnd)
        ? AppError.service_weekSettings_invalid
        : null,
  ]);

  ContextDependentStream<WeekSetting> get weekSettingStream => _stream;

  Future<void> _loadData(int? userId) =>
      _weekSettingDao.loadUserSettings(userId);

  Future<void> updateWeekSettings(WeekSetting settings) =>
      runContextDependentAction(
        _userService.currentUserStream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) => validateAndRun(
          weekSettingsValidator,
          settings,
          () => _weekSettingDao.updateByUserId(user.id, settings),
        ),
      );

  @override
  void close() {
    super.close();
    _userService.close();
  }
}
