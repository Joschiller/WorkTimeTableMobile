import 'dart:ui';

enum EventType {
  publicHoliday(
    priority: 0,
    displayValue: 'Public holiday',
    color: Color.fromARGB(255, 145, 216, 78),
  ),
  vacation(
    priority: 4,
    displayValue: 'Vacation',
    color: Color.fromARGB(255, 102, 152, 54),
  ),
  sickDay(
    priority: 1,
    displayValue: 'Sick day',
    color: Color.fromARGB(255, 152, 54, 54),
  ),
  dayOff(
    priority: 2,
    displayValue: 'Day off',
    color: Color.fromARGB(255, 64, 190, 179),
  ),
  businessTrip(
    priority: 3,
    displayValue: 'Business trip',
    color: Color.fromARGB(255, 64, 66, 190),
  );

  const EventType({
    required this.priority,
    required this.displayValue,
    required this.color,
  });

  final int priority;
  final String displayValue;
  final Color color;
}
