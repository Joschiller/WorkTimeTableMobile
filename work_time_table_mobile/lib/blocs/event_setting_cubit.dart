import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_cubit.dart';

class EventSettingCubit extends ContextDependentCubit<List<EventSetting>> {
  EventSettingCubit(this._eventSettingsService) : super() {
    _eventSettingsService.weekSettingStream.listen(emit);
  }

  final EventSettingService _eventSettingsService;

  Future<void> addEvent(EventSetting event) =>
      _eventSettingsService.addEvent(event);

  Future<void> deleteEvent(int id, bool isConfirmed) =>
      _eventSettingsService.deleteEvent(id, isConfirmed);
}
