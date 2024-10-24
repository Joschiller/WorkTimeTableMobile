import 'package:work_time_table_mobile/models/global_setting_key.dart';
import 'package:work_time_table_mobile/models/settings_map.dart';
import 'package:work_time_table_mobile/services/global_setting_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_cubit.dart';

class GlobalSettingCubit extends ContextDependentCubit<SettingsMap> {
  GlobalSettingCubit(this._globalSettingService) : super() {
    _globalSettingService.globalSettingStream.stream.listen(emit);
  }

  final GlobalSettingService _globalSettingService;

  Future<void> updateSetting(
    GlobalSettingKey key,
    String? value,
  ) =>
      _globalSettingService.updateByKey(key, value);
}
