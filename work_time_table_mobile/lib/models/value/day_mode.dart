import 'package:work_time_table_mobile/models/event_setting/event_type.dart';

enum DayMode {
  nonWorkDay(displayValue: 'Non work day'),
  workDay(displayValue: 'Work day'),
  publicHoliday(displayValue: 'Public holiday'),
  vacation(displayValue: 'Vacation'),
  sickDay(displayValue: 'Sick day'),
  dayOff(displayValue: 'Day off'),
  businessTrip(displayValue: 'Business trip');

  const DayMode({required this.displayValue});

  final String displayValue;

  static DayMode fromEventType(EventType eventType) => switch (eventType) {
        EventType.publicHoliday => DayMode.publicHoliday,
        EventType.vacation => DayMode.vacation,
        EventType.sickDay => DayMode.sickDay,
        EventType.dayOff => DayMode.dayOff,
        EventType.businessTrip => DayMode.businessTrip,
      };
}
