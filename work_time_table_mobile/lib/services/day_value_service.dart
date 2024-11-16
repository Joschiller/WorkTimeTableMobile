import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/event_type.dart';
import 'package:work_time_table_mobile/models/value/day_mode.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/event_service.dart';

class DayValueService {
  const DayValueService(this._eventService);

  final EventService _eventService;

  DayValue getInitialValueForDay(
    DateTime date,
    WeekSetting weekSetting,
    List<EventSetting> eventSettings,
  ) {
    final daySetting =
        weekSetting.weekDaySettings[DayOfWeek.fromDateTime(date)];

    // if nonWorkDay -> nonWorkDay
    if (daySetting == null) {
      return DayValue(
        date: date,
        firstHalfMode: DayMode.nonWorkDay,
        secondHalfMode: DayMode.nonWorkDay,
        workTimeStart: 0,
        workTimeEnd: 0,
        breakDuration: 0,
      );
    }

    // check if any event is set for part of the day
    var modeForFirstHalfOfDay = DayMode.workDay;
    var modeForSecondHalfOfDay = DayMode.workDay;

    for (final eventType in EventType.values
      ..sort((a, b) => a.priority - b.priority)) {
      for (final event
          in eventSettings.where((event) => event.eventType == eventType)) {
        // check event range
        final eventInfluence = _eventService.doesEventAffectDate(date, event);

        if (eventInfluence.firstHalf &&
            modeForFirstHalfOfDay == DayMode.workDay) {
          modeForFirstHalfOfDay = DayMode.fromEventType(event.eventType);
        }

        if (eventInfluence.secondHalf &&
            modeForSecondHalfOfDay == DayMode.workDay) {
          modeForSecondHalfOfDay = DayMode.fromEventType(event.eventType);
        }

        if (modeForFirstHalfOfDay != DayMode.workDay &&
            modeForSecondHalfOfDay != DayMode.workDay) {
          break;
        }
      }

      if (modeForFirstHalfOfDay != DayMode.workDay &&
          modeForSecondHalfOfDay != DayMode.workDay) {
        break;
      }
    }

    if (modeForFirstHalfOfDay != DayMode.workDay &&
        modeForSecondHalfOfDay != DayMode.workDay) {
      // found a non working day
      return DayValue(
        date: date,
        firstHalfMode: modeForFirstHalfOfDay,
        secondHalfMode: modeForSecondHalfOfDay,
        workTimeStart: 0,
        workTimeEnd: 0,
        breakDuration: 0,
      );
    }

    // built up day value respecting default and core time if necessary
    return DayValue(
      date: date,
      firstHalfMode: modeForFirstHalfOfDay,
      secondHalfMode: modeForSecondHalfOfDay,
      workTimeStart: daySetting.defaultWorkTimeStart,
      workTimeEnd: daySetting.defaultWorkTimeEnd,
      breakDuration: daySetting.defaultBreakDuration,
    );
  }
}
