import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_cubit.dart';

typedef EventSettingsCubitState = List<EventSetting>;

class EventSettingsCubit
    extends ContextDependentCubit<EventSettingsCubitState> {
  EventSettingsCubit(this.eventSettingsService) : super() {
    eventSettingsService.eventSettingDao.stream.listen(emit);
  }

  EventSettingService eventSettingsService;

  Future<void> addEvent(EventSetting event) =>
      eventSettingsService.addEvent(event);

  Future<void> deleteEvent(int id, bool isConfirmed) =>
      eventSettingsService.deleteEvent(id, isConfirmed);
}
