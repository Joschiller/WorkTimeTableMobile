import 'dart:async';

import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/week_setting_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_cubit.dart';

class WeekSettingCubit extends ContextDependentCubit<WeekSetting> {
  late StreamSubscription _subscription;

  WeekSettingCubit(this._weekSettingService) : super() {
    _subscription = _weekSettingService.weekSettingStream.stream.listen(emit);
  }

  final WeekSettingService _weekSettingService;

  Future<void> updateWeekSettings(WeekSetting settings) =>
      _weekSettingService.updateWeekSettings(settings);

  @override
  Future<void> close() {
    _subscription.cancel();
    _weekSettingService.close();
    return super.close();
  }
}
