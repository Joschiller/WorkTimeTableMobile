import 'dart:async';

import 'package:work_time_table_mobile/models/event_setting/evaluated_event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/services/event_service.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_cubit.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

typedef EvaluatedEventSettingCubitState = ({
  List<EventSetting> events,
  Map<DateTime, List<EvaluatedEventSetting>> evaluatedEvents,
});

ContextDependentValue<EvaluatedEventSettingCubitState> _buildStateFromEventList(
        ContextDependentValue<List<EventSetting>> eventState) =>
    switch (eventState) {
      NoContextValue<List<EventSetting>>() => NoContextValue(),
      ContextValue<List<EventSetting>>(value: final events) => ContextValue((
          events: events,
          evaluatedEvents: {},
        )),
    };

class EvaluatedEventSettingCubit
    extends ContextDependentCubit<EvaluatedEventSettingCubitState> {
  late StreamSubscription _subscription;

  EvaluatedEventSettingCubit(this._eventService, this._eventSettingService)
      : super(_buildStateFromEventList(
            _eventSettingService.eventSettingStream.state)) {
    _subscription = _eventSettingService.eventSettingStream.stream
        // clear cache and reload events
        .listen((event) => emit(_buildStateFromEventList(event)));
  }

  final EventService _eventService;
  final EventSettingService _eventSettingService;

  // clear cache and reload events
  void resetCache() => emit(
      _buildStateFromEventList(_eventSettingService.eventSettingStream.state));

  List<EvaluatedEventSetting> getEventsForDay(DateTime day) {
    switch (state) {
      case NoContextValue<EvaluatedEventSettingCubitState>():
        return [];
      case ContextValue<EvaluatedEventSettingCubitState>(value: final events):
        if (events.evaluatedEvents.keys.contains(day)) {
          // cached value
          return events.evaluatedEvents[day]!;
        }

        // evaluate events
        final evaluatedEvent = _eventService.getEventsAffectingDate(
          day,
          events.events,
        )..sort((a, b) =>
            a.eventSetting.eventType.priority -
            b.eventSetting.eventType.priority);
        emit(ContextValue((
          events: events.events,
          evaluatedEvents: {
            ...events.evaluatedEvents,
            day: evaluatedEvent,
          }
        )));
        return evaluatedEvent;
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _eventSettingService.close();
    return super.close();
  }
}
