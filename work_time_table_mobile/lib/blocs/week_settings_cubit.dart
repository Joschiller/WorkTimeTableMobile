import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/week_setting_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_cubit.dart';

class WeekSettingsCubit extends ContextDependentCubit<WeekSetting> {
  WeekSettingsCubit(this._weekSettingsService) : super() {
    _weekSettingsService.weekSettingStream.listen(emit);
  }

  final WeekSettingService _weekSettingsService;

  Future<void> updateWeekSettings(WeekSetting settings) =>
      _weekSettingsService.updateWeekSettings(settings);
}
