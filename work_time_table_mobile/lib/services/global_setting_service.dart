import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/global_setting_dao.dart';
import 'package:work_time_table_mobile/models/global_setting_key.dart';
import 'package:work_time_table_mobile/models/settings_map.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/streamable_service.dart';

final _stream = ContextDependentStream<SettingsMap>();

class GlobalSettingService extends StreamableService {
  GlobalSettingService(this._currentUserDao, this._globalSettingDao) {
    _currentUserDao.stream.stream
        .listen((selectedUser) => runContextDependentAction(
              selectedUser,
              () => _loadData(null),
              (user) => _loadData(user.id),
            ));
    prepareListen(_globalSettingDao.stream, _stream);
  }

  final CurrentUserDao _currentUserDao;
  final GlobalSettingDao _globalSettingDao;

  ContextDependentStream<SettingsMap> get globalSettingStream => _stream;

  Future<void> _loadData(int? userId) =>
      _globalSettingDao.loadUserValues(userId);

  Future<void> updateByKey(
    GlobalSettingKey key,
    String? value,
  ) =>
      runContextDependentAction(
        _currentUserDao.stream.state,
        () async => Future.error(AppError.service_noUserLoaded),
        // TODO: Validation
        (user) => _globalSettingDao.updateByUserIdAndKey(user.id, key, value),
      );
}
