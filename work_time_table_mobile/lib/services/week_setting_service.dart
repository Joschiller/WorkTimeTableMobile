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
  }

  final UserService _userService;
  final WeekSettingDao _weekSettingDao;

  static Validator getWeekSettingsValidator(WeekSetting settings) => Validator([
        // targetWorkTimePerWeek <= SUM(timeEquivalent)
        () => settings.targetWorkTimePerWeek >
                (settings.weekDaySettings.values.isEmpty
                    ? 0
                    : settings.weekDaySettings.values
                        .map((s) => s.timeEquivalent)
                        .reduce((a, b) => a + b))
            ? AppError.service_weekSettings_invalidTargetWorktime
            : null,
        // each day of week is unique -> technical validation
        () => settings.weekDaySettings.entries
                .any((day) => day.key != day.value.dayOfWeek)
            ? AppError.service_weekSettings_invalid
            : null,
        // (start == null) == (end == null) -> technical validation
        () => settings.weekDaySettings.values.any((day) =>
                (day.defaultWorkTimeStart == null) !=
                (day.defaultWorkTimeEnd == null))
            ? AppError.service_weekSettings_invalid
            : null,
        () => settings.weekDaySettings.values.any((day) =>
                (day.mandatoryWorkTimeStart == null) !=
                (day.mandatoryWorkTimeEnd == null))
            ? AppError.service_weekSettings_invalid
            : null,
        // start <= end -> technical validation
        () => settings.globalWeekDaySetting.defaultWorkTimeStart >
                settings.globalWeekDaySetting.defaultWorkTimeEnd
            ? AppError.service_weekSettings_invalid
            : null,
        () => settings.globalWeekDaySetting.defaultMandatoryWorkTimeStart >
                settings.globalWeekDaySetting.defaultMandatoryWorkTimeEnd
            ? AppError.service_weekSettings_invalid
            : null,
        () => settings.weekDaySettings.values.any((day) =>
                (day.defaultWorkTimeStart ?? 0) > (day.defaultWorkTimeEnd ?? 0))
            ? AppError.service_weekSettings_invalid
            : null,
        () => settings.weekDaySettings.values.any((day) =>
                (day.mandatoryWorkTimeStart ?? 0) >
                (day.mandatoryWorkTimeEnd ?? 0))
            ? AppError.service_weekSettings_invalid
            : null,
        // default time respects manatory time -> technical validation
        () => settings.globalWeekDaySetting.defaultWorkTimeStart >
                settings.globalWeekDaySetting.defaultMandatoryWorkTimeStart
            ? AppError.service_weekSettings_invalid
            : null,
        () => settings.globalWeekDaySetting.defaultWorkTimeEnd <
                settings.globalWeekDaySetting.defaultMandatoryWorkTimeEnd
            ? AppError.service_weekSettings_invalid
            : null,
        () => settings.weekDaySettings.values.any((day) =>
                (day.defaultWorkTimeStart ??
                    settings.globalWeekDaySetting.defaultWorkTimeStart) >
                (day.mandatoryWorkTimeStart ??
                    settings
                        .globalWeekDaySetting.defaultMandatoryWorkTimeStart))
            ? AppError.service_weekSettings_invalid
            : null,
        () => settings.weekDaySettings.values.any((day) =>
                (day.defaultWorkTimeEnd ??
                    settings.globalWeekDaySetting.defaultWorkTimeEnd) <
                (day.mandatoryWorkTimeEnd ??
                    settings.globalWeekDaySetting.defaultMandatoryWorkTimeEnd))
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
          getWeekSettingsValidator(settings),
          () => _weekSettingDao.updateByUserId(user.id, settings),
        ),
      );

  @override
  void close() {
    super.close();
    _userService.close();
  }
}
