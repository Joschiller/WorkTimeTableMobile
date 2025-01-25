import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/day_value_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/daos/global_setting_dao.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/daos/week_value_dao.dart';
import 'package:work_time_table_mobile/dto/user_dto.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/settings_map.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/services/global_setting_service.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/services/week_setting_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/utils.dart';
import 'package:work_time_table_mobile/validate_and_run.dart';

class ExportService {
  ExportService(
    this._currentUserDao,
    this._weekSettingDao,
    this._eventSettingDao,
    this._globalSettingDao,
    this._dayValueDao,
    this._weekValueDao,
    this._userService,
  );

  final CurrentUserDao _currentUserDao;
  final WeekSettingDao _weekSettingDao;
  final EventSettingDao _eventSettingDao;
  final GlobalSettingDao _globalSettingDao;
  final DayValueDao _dayValueDao;
  final WeekValueDao _weekValueDao;

  final UserService _userService;

  ContextDependentValue<
      ({
        User user,
        WeekSetting weekSetting,
        List<EventSetting> eventSettings,
        SettingsMap globalSettings,
        List<DayValue> dayValues,
        List<WeekValue> weekValues,
      })> getAllValues() => runContextDependentAction(
        _currentUserDao.stream.state,
        () => NoContextValue(),
        (user) => runContextDependentAction(
          _weekSettingDao.stream.state,
          () => NoContextValue(),
          (weekSetting) => runContextDependentAction(
            _eventSettingDao.stream.state,
            () => NoContextValue(),
            (eventSettings) => runContextDependentAction(
              _globalSettingDao.stream.state,
              () => NoContextValue(),
              (globalSettings) => runContextDependentAction(
                _dayValueDao.stream.state,
                () => NoContextValue(),
                (dayValues) => runContextDependentAction(
                  _weekValueDao.stream.state,
                  () => NoContextValue(),
                  (weekValues) => ContextValue((
                    user: user,
                    weekSetting: weekSetting,
                    eventSettings: eventSettings,
                    globalSettings: globalSettings,
                    dayValues: dayValues,
                    weekValues: weekValues,
                  )),
                ),
              ),
            ),
          ),
        ),
      );

  Uint8List _stringToUint8List(String data) =>
      Uint8List.fromList(utf8.encode(data));

  Future<void> exportCurrentUser() async {
    return runContextDependentAction(
      getAllValues(),
      () async => Future.error(AppError.service_noUserLoaded),
      (values) async {
        try {
          final targetFile = await FilePicker.platform.saveFile(
            dialogTitle: 'Select a location for your export file',
            fileName:
                '${values.user.name} ${technicalDateFormat.format(DateTime.now())}.json',
            allowedExtensions: ['json'],
            bytes: _stringToUint8List(
              jsonEncode(
                UserDto.fromAppModel(
                  values.user,
                  values.weekSetting,
                  values.eventSettings,
                  values.globalSettings,
                  values.dayValues,
                  values.weekValues,
                ),
              ),
            ),
          );
          if (targetFile == null) {
            return Future.error(AppError.service_export_error_export_aborted);
          }
        } catch (e) {
          return Future.error(AppError.service_export_error_export);
        }
      },
    );
  }
}
