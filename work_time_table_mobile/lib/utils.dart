import 'package:flutter/material.dart';

extension IsBlank on String {
  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => trim().isNotEmpty;
}

extension DateTimeToDay on DateTime {
  DateTime toDay() => DateTime(year, month, day);
}

extension IntToTimeOfDay on int {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: this ~/ 60, minute: this % 60);
}

extension TimeOfDayToInt on TimeOfDay {
  int toInt() => 60 * hour + minute;
}
