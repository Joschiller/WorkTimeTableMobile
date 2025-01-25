import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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
import 'package:work_time_table_mobile/models/value/day_mode.dart';
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
import 'package:work_time_table_mobile/validator.dart';

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
      })> _getAllValues() => runContextDependentAction(
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
      _getAllValues(),
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
          if (kDebugMode) {
            print(e);
          }
          return Future.error(AppError.service_export_error_export);
        }
      },
    );
  }

  Validator _getDaysValidator(List<DayValue> days) => Validator([
        // whole weeks
        () => days.length % 7 != 0
            ? AppError.service_export_error_import_invalid
            : null,
        // day of week in correct order
        () => days.asMap().entries.any((element) =>
                (element.key % 7) + 1 != element.value.date.weekday)
            ? AppError.service_export_error_import_invalid
            : null,
        // all consecutive days (days in ascending order and count of days equals total timespan)
        () => days.asMap().entries.any((element) =>
                element.key != 0 &&
                !days[element.key - 1].date.isBefore(element.value.date))
            ? AppError.service_export_error_import_invalid
            : null,
        () => days.isNotEmpty &&
                days.first.date
                        .add(Duration(days: days.length - 1))
                        .compareTo(days.last.date) !=
                    0
            ? AppError.service_export_error_import_invalid
            : null,
        // validate each day
        () => days
            .map(_getDayValidator)
            .map((v) => v.validate())
            .where((v) => v != null)
            .firstOrNull,
      ]);

  Validator _getDayValidator(DayValue day) => Validator([
        // empty values if completely not workDay
        () => day.firstHalfMode != DayMode.workDay &&
                day.secondHalfMode != DayMode.workDay &&
                (day.workTimeStart != 0 ||
                    day.workTimeEnd != 0 ||
                    day.breakDuration != 0)
            ? AppError.service_export_error_import_invalid
            : null,
        // start <= end
        () => day.workTimeStart > day.workTimeEnd
            ? AppError.service_export_error_import_invalid
            : null,
        // settings are not relevant and therefore, the settings are not validated
      ]);

  Validator _getWeeksValidator(List<DayValue> days, List<WeekValue> weeks) =>
      Validator([
        // all days for each week exist
        () => weeks.any(
              (week) => [
                for (var i = 0; i < 7; i++) i,
              ].any(
                (i) => !days.any(
                  (d) =>
                      d.date.compareTo(
                        week.weekStartDate.add(Duration(days: i)),
                      ) ==
                      0,
                ),
              ),
            )
                ? AppError.service_export_error_import_invalid
                : null,
        // all consecutive weeks (weeks in ascending order and count of weeks equals total timespan)
        () => weeks.asMap().entries.any((element) =>
                element.key != 0 &&
                !weeks[element.key - 1]
                    .weekStartDate
                    .isBefore(element.value.weekStartDate))
            ? AppError.service_export_error_import_invalid
            : null,
        () => weeks.isNotEmpty &&
                weeks.first.weekStartDate
                        .add(Duration(days: (weeks.length - 1) * 7))
                        .compareTo(weeks.last.weekStartDate) !=
                    0
            ? AppError.service_export_error_import_invalid
            : null,
      ]);

  Future<void> import() async {
    try {
      final pickedFile = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select a user file',
        allowedExtensions: ['json'],
        type: FileType.custom,
        allowMultiple: false,
      );
      final sourceFile = pickedFile?.paths.firstOrNull;
      if (sourceFile == null) {
        return Future.error(AppError.service_export_error_import_aborted);
      }
      final values = UserDto.fromJson(
        jsonDecode(
          File(sourceFile).readAsStringSync(),
        ),
      ).toAppModel();

      // user insertion is run via the services to validate the value
      // TODO: if the user already exists -> ask user whether to override the existing user or abort the import (would clear all data and then re-create the user)
      final userId = await _userService.addUser(values.user.name);

      // all other values are validated using the validators
      await validateAndRun(
        WeekSettingService.getWeekSettingsValidator(values.weekSetting),
        () => _weekSettingDao.updateByUserId(
          userId,
          values.weekSetting,
          reload: false,
        ),
      );
      await Future.wait(
        values.eventSettings.map(
          (event) => validateAndRun(
            EventSettingService.getEventValidator(event),
            () => _eventSettingDao.create(userId, event, reload: false),
          ),
        ),
      );
      await Future.wait(
        values.globalSettings.entries.map(
          (setting) => validateAndRun(
            GlobalSettingService.getGlobalSettingValidator(
              setting.key,
              setting.value,
            ),
            () => _globalSettingDao.updateByUserIdAndKey(
              userId,
              setting.key,
              setting.value,
              reload: false,
            ),
          ),
        ),
      );
      await validateAndRun(
        _getDaysValidator(values.dayValues),
        () => Future.wait(
          values.dayValues.map(
            (day) => _dayValueDao.upsert(userId, day, reload: false),
          ),
        ),
      );
      await validateAndRun(
        _getWeeksValidator(values.dayValues, values.weekValues),
        () => Future.wait(
          values.weekValues.map(
            (week) => _weekValueDao.create(userId, week, reload: false),
          ),
        ),
      );

      // reload current user, in case the current user was modified by the import
      await _currentUserDao.loadData();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e == AppError.service_user_duplicateName) {
        return Future.error(AppError.service_export_error_import_duplicate);
      }
      return Future.error(AppError.service_export_error_import);
    }
  }
}
