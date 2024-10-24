enum EventType {
  publicHoliday(priority: 0),
  vacation(priority: 4),
  sickDay(priority: 1),
  dayOff(priority: 2),
  businessTrip(priority: 3);

  const EventType({required this.priority});

  final int priority;
}
