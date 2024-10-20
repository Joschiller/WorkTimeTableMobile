import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/week_setting_service.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/context/context_dependent_cubit.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/context/context_dependent_value.dart';

typedef WeekSettingsCubitState = ContextDependentValue<WeekSetting>;

class WeekSettingsCubit extends ContextDependentCubit<WeekSetting> {
  WeekSettingsCubit(this.weekSettingsService) : super() {
    weekSettingsService.weekSettingDao.stream.listen(emit);
  }

  WeekSettingService weekSettingsService;

  Future<void> updateWeekSettings(WeekSetting settings) =>
      weekSettingsService.updateWeekSettings(settings);
}
