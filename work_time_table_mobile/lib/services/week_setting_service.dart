import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/utils.dart';

class WeekSettingService {
  WeekSettingService(this.currentUserDao, this.weekSettingDao) {
    currentUserDao.stream.listen((selectedUser) => runContextDependentAction(
          selectedUser,
          () => _loadData(null),
          (user) => _loadData(user.id),
        ));
  }

  final CurrentUserDao currentUserDao;
  final WeekSettingDao weekSettingDao;

  Future<void> _loadData(int? userId) =>
      weekSettingDao.loadUserSettings(userId);

  Future<void> updateWeekSettings(WeekSetting settings) =>
      runContextDependentAction(
        currentUserDao.data,
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
          () => weekSettingDao.updateByUserId(user.id, settings),
        ),
      );
}
