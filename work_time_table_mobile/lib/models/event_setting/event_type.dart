enum EventType {
  publicHoliday(priority: 0, displayValue: 'Public holiday'),
  vacation(priority: 4, displayValue: 'Vacation'),
  sickDay(priority: 1, displayValue: 'Sick day'),
  dayOff(priority: 2, displayValue: 'Day off'),
  businessTrip(priority: 3, displayValue: 'Business trip');

  const EventType({required this.priority, required this.displayValue});

  final int priority;
  final String displayValue;
}
