import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/global_setting_dao.dart';
import 'package:work_time_table_mobile/models/global_setting_key.dart';
import 'package:work_time_table_mobile/models/settings_map.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/streamable_service.dart';
import 'package:work_time_table_mobile/validate_and_run.dart';
import 'package:work_time_table_mobile/validator.dart';

final _stream = ContextDependentStream<SettingsMap>();

class GlobalSettingService extends StreamableService {
  GlobalSettingService(this._userService, this._globalSettingDao) {
    registerSubscription(_userService.currentUserStream.stream
        .listen((selectedUser) => runContextDependentAction(
              selectedUser,
              () => _loadData(null),
              (user) => _loadData(user.id),
            )));
    prepareComplexListen(
      [_globalSettingDao.stream],
      () => ContextValue({
        // use default values if no setting exists
        GlobalSettingKey.scrollInterval: runContextDependentAction(
              _globalSettingDao.stream.state,
              () => SettingsMap(),
              (value) => value,
            )[GlobalSettingKey.scrollInterval] ??
            '5',
      }),
      _stream,
    );
    runContextDependentAction(
      _userService.currentUserStream.state,
      () => _loadData(null),
      (user) => _loadData(user.id),
    );
  }

  final UserService _userService;
  final GlobalSettingDao _globalSettingDao;

  static Validator _getGlobalSettingTypeValidator(
    GlobalSettingKeyType type,
    String? value,
  ) =>
      switch (type) {
        GlobalSettingKeyType.int => Validator([
            () => value != null && int.tryParse(value) == null
                ? AppError.service_globalSettings_int_invalid
                : null,
          ]),
      };

  static Validator getGlobalSettingValidator(
    GlobalSettingKey key,
    String? value,
  ) =>
      switch (key) {
        GlobalSettingKey.scrollInterval => Validator([
            () => !_getGlobalSettingTypeValidator(key.type, value).isValid
                ? AppError.service_globalSettings_scrollInterval_invalid
                : null,
          ]),
      };

  ContextDependentStream<SettingsMap> get globalSettingStream => _stream;

  Future<void> _loadData(int? userId) =>
      _globalSettingDao.loadUserValues(userId);

  Future<void> updateByKey(
    GlobalSettingKey key,
    String? value,
  ) =>
      runContextDependentAction(
        _userService.currentUserStream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        (user) => validateAndRun(
          getGlobalSettingValidator(key, value),
          () => _globalSettingDao.updateByUserIdAndKey(user.id, key, value),
        ),
      );

  @override
  void close() {
    super.close();
    _userService.close();
  }
}
