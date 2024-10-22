import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/streamable_service.dart';
import 'package:work_time_table_mobile/utils.dart';

final _stream = ContextDependentStream<WeekSetting>();

class WeekSettingService extends StreamableService {
  WeekSettingService(this._currentUserDao, this._weekSettingDao) {
    _currentUserDao.stream.stream
        .listen((selectedUser) => runContextDependentAction(
              selectedUser,
              () => _loadData(null),
              (user) => _loadData(user.id),
            ));
    prepareListen(_weekSettingDao.stream, _stream);
  }

  final CurrentUserDao _currentUserDao;
  final WeekSettingDao _weekSettingDao;

  Stream<ContextDependentValue<WeekSetting>> get weekSettingStream =>
      _stream.stream;

  Future<void> _loadData(int? userId) =>
      _weekSettingDao.loadUserSettings(userId);

  Future<void> updateWeekSettings(WeekSetting settings) =>
      runContextDependentAction(
        _currentUserDao.stream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) => validateAndRun(
          [
            // targetWorkTimePerWeek <= SUM(timeEquivalent)
            () => settings.targetWorkTimePerWeek >
                    settings.weekDaySettings.values
                        .map((s) => s.timeEquivalent)
                        .reduce((a, b) => a + b)
                ? AppError.service_weekSettings_invalid
                : null,
            // each day of week is unique
            () => settings.weekDaySettings.entries
                    .any((day) => day.key != day.value.dayOfWeek)
                ? AppError.service_weekSettings_invalid
                : null,
            // (start == null) == (end == null)
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
            // start <= end
            () => settings.globalWeekDaySetting.defaultWorkTimeStart >
                    settings.globalWeekDaySetting.defaultWorkTimeEnd
                ? AppError.service_weekSettings_invalid
                : null,
            () => settings.globalWeekDaySetting.defaultMandatoryWorkTimeStart >
                    settings.globalWeekDaySetting.defaultMandatoryWorkTimeEnd
                ? AppError.service_weekSettings_invalid
                : null,
            () => settings.weekDaySettings.values.any((day) =>
                    (day.defaultWorkTimeStart ?? 0) >
                    (day.defaultWorkTimeEnd ?? 0))
                ? AppError.service_weekSettings_invalid
                : null,
            () => settings.weekDaySettings.values.any((day) =>
                    (day.mandatoryWorkTimeStart ?? 0) >
                    (day.mandatoryWorkTimeEnd ?? 0))
                ? AppError.service_weekSettings_invalid
                : null,
            // default time respects manatory time
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
                        settings.globalWeekDaySetting
                            .defaultMandatoryWorkTimeStart))
                ? AppError.service_weekSettings_invalid
                : null,
            () => settings.weekDaySettings.values.any((day) =>
                    (day.defaultWorkTimeEnd ??
                        settings.globalWeekDaySetting.defaultWorkTimeEnd) <
                    (day.mandatoryWorkTimeEnd ??
                        settings
                            .globalWeekDaySetting.defaultMandatoryWorkTimeEnd))
                ? AppError.service_weekSettings_invalid
                : null,
          ],
          () => _weekSettingDao.updateByUserId(user.id, settings),
        ),
      );
}
