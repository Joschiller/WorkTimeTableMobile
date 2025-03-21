import 'dart:async';

import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_cubit.dart';

class EventSettingCubit extends ContextDependentCubit<List<EventSetting>> {
  late StreamSubscription _subscription;

  EventSettingCubit(this._eventSettingService)
      : super(_eventSettingService.eventSettingStream.state) {
    _subscription = _eventSettingService.eventSettingStream.stream.listen(emit);
  }

  final EventSettingService _eventSettingService;

  Future<void> addEvent(EventSetting event) =>
      _eventSettingService.addEvent(event);

  Future<void> updateEvent(EventSetting event) =>
      _eventSettingService.updateEvent(event);

  Future<void> deleteEvents(List<int> ids, bool isConfirmed) =>
      _eventSettingService.deleteEvents(ids, isConfirmed);

  @override
  Future<void> close() {
    _subscription.cancel();
    _eventSettingService.close();
    return super.close();
  }
}
