import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/global_setting_dao.dart';
import 'package:work_time_table_mobile/models/global_setting_key.dart';
import 'package:work_time_table_mobile/models/settings_map.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/streamable_service.dart';

final _stream = ContextDependentStream<SettingsMap>();

class GlobalSettingService extends StreamableService {
  GlobalSettingService(this._userService, this._globalSettingDao) {
    registerSubscription(_userService.currentUserStream.stream
        .listen((selectedUser) => runContextDependentAction(
              selectedUser,
              () => _loadData(null),
              (user) => _loadData(user.id),
            )));
    prepareListen(_globalSettingDao.stream, _stream);
  }

  final UserService _userService;
  final GlobalSettingDao _globalSettingDao;

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
        // TODO: Validation
        (user) => _globalSettingDao.updateByUserIdAndKey(user.id, key, value),
      );

  @override
  void close() {
    super.close();
    _userService.close();
  }
}
