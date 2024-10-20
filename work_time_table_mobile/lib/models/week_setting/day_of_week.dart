enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  static DayOfWeek fromDateTime(DateTime date) =>
      DayOfWeek.values[date.weekday - 1];
}
