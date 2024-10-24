import 'package:work_time_table_mobile/models/event_setting/event_type.dart';

enum DayMode {
  nonWorkDay,
  workDay,
  publicHoliday,
  vacation,
  sickDay,
  dayOff,
  businessTrip;

  static DayMode fromEventType(EventType eventType) => switch (eventType) {
        EventType.publicHoliday => DayMode.publicHoliday,
        EventType.vacation => DayMode.vacation,
        EventType.sickDay => DayMode.sickDay,
        EventType.dayOff => DayMode.dayOff,
        EventType.businessTrip => DayMode.businessTrip,
      };
}
